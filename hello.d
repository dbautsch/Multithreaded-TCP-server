module main;

import std.stdio;
import server;

int main(string[] args)
{
    Server s;

    try
    {
        s = new Server();
        s.StartListening(6000);
    }
    catch (Throwable o)
    {
        writeln("An exception occured:");
        writeln(o.msg);
    }

	return 0;
}
