import server;

class ServerThread : Thread
{
	public:
		this()
		{
			super (&Run);
		}
		
		void Run()
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
		}
}
