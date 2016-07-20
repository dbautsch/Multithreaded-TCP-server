module server;

import std.stdio;
import std.socket;
import std.datetime;

import socket_thread;

class Server
{
    public:
        this()
        {
            //  create working threads, each thread will own couple client sockets
            //  for reading/writing data.
            for (auto i = 0; i < workingThreads.length; ++i)
            {
                workingThreads[i] = new SocketThread;
            }
        }

        void StartListening(uint uPort)
        {
            s = new TcpSocket(AddressFamily.INET);
            //s.blocking(true);

            Address[] addresses = getAddress("127.0.0.1", 6000);

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

            while (true)
            {
                //  check if we can accept
                try
                {
                    Socket clientSocket = s.accept();
                    uint uThreadIDX = GetWorkingThread();
                    workingThreads[uThreadIDX].AddSocket(clientSocket);
                }
                catch (Throwable o)
                {
                    string strException = "An exception occured: " ~ o.msg;
                    writeln(strException);
                }
            }
        }

    private:
        TcpSocket s;

        SocketThread[2] workingThreads;

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
