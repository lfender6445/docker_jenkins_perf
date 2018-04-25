from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import logging
import json
import subprocess
import os

class S(BaseHTTPRequestHandler):

    # support curl -I
    def do_HEAD(s):
        s.send_response(200)
        s.send_header("Content-type", "text/html")
        s.end_headers()

    def _set_response(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        logging.info("GET request,\nPath: %s\nHeaders:\n%s\n", str(self.path), str(self.headers))
        self._set_response()
        if self.path == "/foo":
            print('bar')
        if self.path == "/run_test":
            logging.info('Running taurus...\n')
            self.wfile.write("In {}".format(self.path).encode('utf-8'))
            subprocess.run("bzt taurus.yml", shell=True)
        self.wfile.write("GET request for {}".format(self.path).encode('utf-8'))

    def do_POST(self):
        content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
        post_data = self.rfile.read(content_length) # <--- Gets the data itself
        logging.info("POST request,\nPath: %s\nHeaders:\n%s\n\nBody:\n%s\n",
                str(self.path), str(self.headers), post_data.decode('utf-8'))

        self._set_response()
        self.wfile.write("POST request for {}".format(self.path).encode('utf-8'))

def run(server_class=HTTPServer, handler_class=S, port=8000):
    path='/source/server'
    os.chdir(path)
    logging.basicConfig(level=logging.INFO)
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    logging.info('Starting httpd...\n')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    logging.info('Stopping httpd...\n')

if __name__ == '__main__':
    path="/source/server/"
    os.chdir(path)

    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
