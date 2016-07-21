module socket_thread;

import core.thread;
import core.sync.condition;
import core.sync.mutex;
import std.container;
import std.socket;
import std.stdio;
import std.conv;

import client;

class SocketInfoSet
{
    SocketSet readSet;
    SocketSet writeSet;
    SocketSet errorSet;

    this()
    {
        readSet     = new SocketSet;
        writeSet    = new SocketSet;
        errorSet    = new SocketSet;
    }
};

class ClientInfoSet
{
    Array!Client readSet;
    Array!Client writeSet;
    Array!Client errorSet;
};

class SocketThread : Thread
{
        this()
        {
            mutex           = new Mutex();

            variablesMutex  = new Mutex();
            finish          = new Condition(mutex);

            socketsMutex    = new Mutex();

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
                SocketInfoSet infoSet           = new SocketInfoSet;
                ClientInfoSet clientsInfoSet    = new ClientInfoSet;

                socketsMutex.lock();

                for (int i = 0; i < clientsList.length; ++i)
                {
                    Client client = clientsList[i];

                    infoSet.readSet.add(client.GetSocket());
                    infoSet.writeSet.add(client.GetSocket());
                    infoSet.errorSet.add(client.GetSocket());
                }

                socketsMutex.unlock();

                int iResult = Socket.select(infoSet.readSet, infoSet.writeSet, infoSet.errorSet, dur!"msecs"(250));

                if (iResult < 0)
                    continue;

                writeln("loop");

                SocketSetToClientSet(infoSet, clientsInfoSet);
                DoRead(clientsInfoSet);
                DoWrite(clientsInfoSet);
                HandleErrors(clientsInfoSet);

            }
        }

        void DoRead(ClientInfoSet clientInfoSet)
        {
            foreach (client; clientInfoSet.readSet)
            {
                client.ReadString();
            }
        }

        void DoWrite(ClientInfoSet clientInfoSet)
        {
            foreach (client; clientInfoSet.readSet)
            {
                client.WriteString();
            }
        }

        void HandleErrors(ClientInfoSet clientInfoSet)
        {
            foreach (client; clientInfoSet.readSet)
            {
                client.HandleError();
            }
        }

        void SocketSetToClientSet(SocketInfoSet socketInfoSet, ref ClientInfoSet clientInfoSet)
        {
            socketsMutex.lock();

            foreach (client; clientsList)
            {
                if (socketInfoSet.readSet.isSet(client.GetSocket()))
                {
                    clientInfoSet.readSet.insertBack(client);
                }

                if (socketInfoSet.writeSet.isSet(client.GetSocket()))
                {
                    clientInfoSet.writeSet.insertBack(client);
                }

                if (socketInfoSet.errorSet.isSet(client.GetSocket()))
                {
                    clientInfoSet.errorSet.insertBack(client);
                }
            }

            socketsMutex.unlock();
        }
};
