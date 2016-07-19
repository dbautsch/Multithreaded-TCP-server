module client;

import std.socket;

class Client
{
    public:
        this(Socket socket)
        {
            this.socket = socket;
        }

        ~this()
        {

        }

    private:
        Socket socket;
};
