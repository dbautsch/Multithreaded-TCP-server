module server;

import std.stdio;
import std.socket;
import std.datetime;
import std.conv;
import std.container;
import core.thread;

import socket_thread;

class Server
{
    public:
        this()
        {
            //  create working threads, each thread will own couple client sockets
            //  for reading/writing data.
            for (auto i = 0; i < uThreadsCount; ++i)
            {
                workingThreads.insertBack(new SocketThread);
            }
        }
        
        ~this()
		{
			//!< Server class is destroying.
			
			
		}

        void StartListening(ushort usPort)
        {
            s = new TcpSocket(AddressFamily.INET);
            s.blocking(false);

            Address[] addresses = getAddress("127.0.0.1", usPort);

            if (addresses.length == 0)
            {
                Exception e;
                e.msg = "Failed to obtain localhost address.";
                throw e;
            }

            try
            {
                s.bind(addresses[0]);
                s.listen(25);
            }
            catch (Throwable o)
            {
                writeln(o.msg);
                Exception e;
                e.msg = "Failed to bind or listen.";
                throw e;
            }


            SocketSet readSet = new SocketSet();
            readSet.add(s);

            SocketSet writeSet = new SocketSet();
            writeSet.add(s);

            SocketSet errorSet = new SocketSet();
            errorSet.add(s);

            writeln("Server has been started. Waiting for clients..");
            string strInfo = "Server listening at " ~ addresses[0].toAddrString() ~ ":" ~ text(usPort);
            writeln(strInfo);
            writeln("");

            while (true)
            {
            	Socket clientSocket;
            	
                //  check if we can accept
                try
                {
	                clientSocket = s.accept();
                }
                catch (Throwable o)
                {
                    Thread.sleep(dur!"msecs"(25));
                    continue;
                }
                
                writeln("A client has connected");
				uint uThreadIDX = GetWorkingThread();
				workingThreads[uThreadIDX].AddSocket(clientSocket);
            }
        }

    private:
        TcpSocket s;

        const uint uThreadsCount = 1;

        Array!SocketThread workingThreads;

        uint GetWorkingThread()
        {
            //!< Get working thread index for new incoming connection.
            //!< This function tries to scale the load for all threads.

            uint uIDX = 0;

            if (workingThreads[uIDX].isRunning == false)
                workingThreads[uIDX].start();

            return uIDX;
        }
};
