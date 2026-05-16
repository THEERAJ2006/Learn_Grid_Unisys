#!/usr/bin/env python3
"""
serve_web.py - HTTP server for Flutter Web with wasm MIME type + CORS/COOP/COEP headers.

Serves a Flutter web build with correct MIME types and cross-origin headers needed
for SharedArrayBuffer support (required for Drift's web database).

Usage:
    python3 serve_web.py
    python3 serve_web.py --port 8080
    python3 serve_web.py --host 127.0.0.1 --port 9000

Environment variables:
    WEB_PORT: Server port (default: 8000)
    WEB_HOST: Server host (default: 127.0.0.1)
"""

import argparse
import os
import sys
from pathlib import Path
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse


class CORSRequestHandler(SimpleHTTPRequestHandler):
    """
    HTTP request handler with:
    - Correct MIME type for sqlite3.wasm
    - CORS headers for localhost testing
    - COOP/COEP headers for SharedArrayBuffer support
    """

    def end_headers(self):
        """Add cross-origin and security headers."""
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

    def do_GET(self):
        """Handle GET requests with correct MIME types."""
        if self.path.endswith('.wasm'):
            # Serve wasm with correct MIME type
            self.send_response(200)
            self.send_header('Content-Type', 'application/wasm')
            self.send_header('Content-Length', self._get_file_size(self.path))
            self.end_headers()
            self._send_file_content()
        else:
            # Default handling
            super().do_GET()

    def do_OPTIONS(self):
        """Handle OPTIONS requests for CORS preflight."""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.end_headers()

    def _get_file_size(self, path):
        """Get file size in bytes."""
        try:
            file_path = self.translate_path(path)
            return os.path.getsize(file_path)
        except Exception:
            return 0

    def _send_file_content(self):
        """Send file content to client."""
        try:
            file_path = self.translate_path(self.path)
            with open(file_path, 'rb') as f:
                self.wfile.write(f.read())
        except Exception as e:
            self.send_error(404, str(e))

    def log_message(self, format, *args):
        """Override to provide cleaner logging."""
        print(f'[{self.client_address[0]}] {format % args}')


def main():
    """Parse args and start HTTP server."""
    parser = argparse.ArgumentParser(
        description='Serve Flutter web build with wasm MIME type and CORS headers.'
    )
    parser.add_argument(
        '--port',
        type=int,
        default=int(os.getenv('WEB_PORT', '8000')),
        help='Port to serve on (default: 8000 or WEB_PORT env var)'
    )
    parser.add_argument(
        '--host',
        default=os.getenv('WEB_HOST', '127.0.0.1'),
        help='Host to bind to (default: 127.0.0.1 or WEB_HOST env var)'
    )
    parser.add_argument(
        '--build-dir',
        default='build/web',
        help='Path to Flutter build/web directory (default: build/web)'
    )

    args = parser.parse_args()

    # Change to build directory
    build_path = Path(args.build_dir)
    if not build_path.exists():
        print(f'Error: Build directory not found: {build_path}', file=sys.stderr)
        sys.exit(1)

    os.chdir(build_path)
    print(f'Serving Flutter web build from: {build_path.absolute()}')

    # Start server
    server_address = (args.host, args.port)
    httpd = HTTPServer(server_address, CORSRequestHandler)

    print(f'Server running at http://{args.host}:{args.port}')
    print('Headers:')
    print('  - Access-Control-Allow-Origin: *')
    print('  - Cross-Origin-Opener-Policy: same-origin')
    print('  - Cross-Origin-Embedder-Policy: require-corp')
    print('  - *.wasm MIME type: application/wasm')
    print('Press Ctrl+C to stop.')

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print('\nShutting down server...')
        httpd.shutdown()
        sys.exit(0)


if __name__ == '__main__':
    main()
