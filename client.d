module client;

import std.socket;
import std.stdio;

class Client
{
    public:
        this(Socket socket)
        {
            this.socket = socket;
            bIsReading = false;
        }

        ~this()
        {

        }

        void WriteString()
        {
            //!< Function is called by SocketThread class instance when socket is ready
            //!< to write data.

            writeln("Socket can write");
        }

        void ReadString()
        {
            //!< Function is called by SocketThread class instance when socket is ready
            //!< to read some data.

            writeln("Socket can read");
        }

        void HandleError()
        {
            //!< Function is called by SocketThread class instance when socket is in the
            //!< error state.

            writeln("Socket error");
        }

        Socket GetSocket()
        {
            return socket;
        }

    private:
        Socket socket;

        bool bIsReading;
};
