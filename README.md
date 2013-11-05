My Mini Webserver
=======

Details
=======
This is a mini web server written in Ruby.  This is an exercise in learning how web servers work.  This was created following the guide provided by Luke Francl, https://practicingruby.com/articles/implementing-an-http-file-server?u=2c59db4496.

I customized this in a small way.  The server looks for '..' in the path being sent in by the user (through curl since browsers remove such things), and then removes the '..' from the path to keep the user from accessing files in the system (above the ROOT).  The example showed how to do this step by step.  I added a little code to accummulate "TSK" messages, with one "TSK!" added for each '..' found in the path.  At the end, when my server serves the page to the client, the accumulated "TSK" messages will also be served, but only if the client was naughty and included '..' in the path.


