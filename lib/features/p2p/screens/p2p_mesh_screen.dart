import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/p2p/p2p_service.dart';
import '../widgets/peer_card.dart';
import '../widgets/transfer_progress_widget.dart';

/// P2P Mesh Networking Screen
/// Displays discovered peers, facilitates content and model sharing
class P2PMeshScreen extends ConsumerStatefulWidget {
  const P2PMeshScreen({super.key});

  @override
  ConsumerState<P2PMeshScreen> createState() => _P2PMeshScreenState();
}

class _P2PMeshScreenState extends ConsumerState<P2PMeshScreen> {
  late StreamSubscription<P2PEvent> _eventSubscription;
  bool _isAdvertising = false;
  bool _isDiscovering = false;
  final Map<String, double> _transferProgress = {}; // peerId -> progress

  @override
  void initState() {
    super.initState();
    _initializeP2P();
  }

  Future<void> _initializeP2P() async {
    final p2pService = ref.read(p2pServiceProvider);
    
    // Initialize service
    await p2pService.init(
      deviceId: 'device_${DateTime.now().millisecondsSinceEpoch}',
      deviceName: 'LearnGrid Device',
    );
    
    // Listen to P2P events
    _eventSubscription = p2pService.events.listen((event) {
      _handleP2PEvent(event);
    });
    
    setState(() {});
  }

  void _handleP2PEvent(P2PEvent event) {
    setState(() {
      switch (event.type) {
        case P2PEventType.peerDiscovered:
          debugPrint('✓ Peer discovered: ${event.peerName}');
          break;
        case P2PEventType.peerLost:
          debugPrint('✗ Peer lost: ${event.peerId}');
          _transferProgress.remove(event.peerId);
          break;
        case P2PEventType.transferProgress:
          if (event.peerId != null && event.progress != null) {
            _transferProgress[event.peerId!] = event.progress!;
          }
          break;
        case P2PEventType.transferComplete:
          debugPrint('✓ Transfer complete: ${event.contentId}');
          if (event.peerId != null) {
            _transferProgress.remove(event.peerId);
          }
          break;
        case P2PEventType.transferFailed:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transfer failed: ${event.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
          if (event.peerId != null) {
            _transferProgress.remove(event.peerId);
          }
          break;
        default:
          break;
      }
    });
  }

  void _toggleAdvertising() async {
    final p2pService = ref.read(p2pServiceProvider);
    if (_isAdvertising) {
      p2pService.stopAdvertising();
    } else {
      p2pService.startAdvertising();
    }
    setState(() => _isAdvertising = !_isAdvertising);
  }

  void _toggleDiscovery() async {
    final p2pService = ref.read(p2pServiceProvider);
    if (_isDiscovering) {
      p2pService.stopDiscovery();
    } else {
      p2pService.startDiscovery();
    }
    setState(() => _isDiscovering = !_isDiscovering);
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p2pService = ref.watch(p2pServiceProvider);
    final peers = p2pService.discoveredPeers;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'P2P Mesh Network',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Control Panel
              _buildControlPanel(),
              
              const SizedBox(height: 24),
              
              // Status Indicators
              _buildStatusIndicators(),
              
              const SizedBox(height: 24),
              
              // Discovered Peers Section
              _buildPeersSection(peers),
              
              const SizedBox(height: 24),
              
              // Active Transfers
              if (_transferProgress.isNotEmpty) ...[
                _buildTransfersSection(),
                const SizedBox(height: 24),
              ],
              
              // Network Statistics
              _buildNetworkStats(peers),
              
              const SizedBox(height: 24),
            ],
          ).animate().fadeIn(),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Network Control',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  label: _isAdvertising ? 'Broadcasting' : 'Start Broadcast',
                  icon: Icons.broadcast_on_personal,
                  isActive: _isAdvertising,
                  onPressed: _toggleAdvertising,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildControlButton(
                  label: _isDiscovering ? 'Scanning' : 'Start Scan',
                  icon: Icons.radar,
                  isActive: _isDiscovering,
                  onPressed: _toggleDiscovery,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppTheme.primary : AppTheme.surfaceVariant,
        foregroundColor: isActive ? Colors.white : AppTheme.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStatusIndicators() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatusBadge(
            label: 'Broadcasting',
            isActive: _isAdvertising,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatusBadge(
            label: 'Scanning',
            isActive: _isDiscovering,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required String label,
    required bool isActive,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? color : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeersSection(List<DiscoveredPeer> peers) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discovered Peers',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${peers.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (peers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.radar,
                      size: 48,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No peers discovered',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enable scanning and broadcasting to find nearby devices',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: peers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final peer = peers[index];
                final progress = _transferProgress[peer.id];
                
                return PeerCard(
                  peer: peer,
                  progress: progress,
                  onShare: () => _handlePeerShare(peer),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTransfersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Transfers',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._transferProgress.entries.map((entry) {
            return TransferProgressWidget(
              peerId: entry.key,
              progress: entry.value,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNetworkStats(List<DiscoveredPeer> peers) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Network Statistics',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatRow('Active Peers', '${peers.length}'),
            const SizedBox(height: 8),
            _buildStatRow('Status', _isAdvertising && _isDiscovering ? 'Online' : 'Idle'),
            const SizedBox(height: 8),
            _buildStatRow('Mode', _isAdvertising ? 'Broadcasting' : 'Listening'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  void _handlePeerShare(DiscoveredPeer peer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share with Peer'),
        content: const Text('Select what to share:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Content sharing coming soon!')),
              );
            },
            child: const Text('Share Content'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Model sharing coming soon!')),
              );
            },
            child: const Text('Share Model'),
          ),
        ],
      ),
    );
  }
}
