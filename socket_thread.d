module socket_thread;

import core.thread;
import core.sync.condition;
import core.sync.mutex;
import std.container;
import std.socket;

import client;

class SocketThread : Thread
{
        this()
        {
            mutex = new Mutex();

            variablesMutex = new Mutex();
            finish = new Condition(mutex);

            socketsMutex = new Mutex();

            super (&Run);
        }

        void AddSocket(Socket s)
        {
            socketsMutex.lock();
            clientsList.insertBack(new Client(s));
            socketsMutex.unlock();


        }

        void Finish()
        {
            finish.notifyAll();
        }

        uint ClientCount()
        {
            uint uRet;

            socketsMutex.lock();
            uRet = cast(uint) clientsList.length;
            socketsMutex.unlock();

            return uRet;
        }

    private:
        Condition finish;
        Mutex mutex;
        Mutex variablesMutex;
        Mutex socketsMutex;
        Array!Client clientsList;
        bool bUpdateSet;

        void Run()
        {
            while (true)
            {
                SocketSet readSet = new SocketSet();
                //readSet.add(s);

                SocketSet writeSet = new SocketSet();
                //writeSet.add(s);

                SocketSet errorSet = new SocketSet();
                //errorSet.add(s);

                int iResult = Socket.select(readSet, writeSet, errorSet, dur!"msecs"(25));

                if (iResult < 0)
                    continue;
            }
        }
};
