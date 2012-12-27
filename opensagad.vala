// 
//  main.vala
//  
//  Author:
//       Edwin De La Cruz <edwinspire@gmail.com>
//  
//  Copyright (c) 2011 edwinspire
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
// 
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
using GLib;
using edwinspire.OpenSAGA;

//using Gee;
//using edwinspire.UiWeb.Server;
//using Xml;

public class RunOpenSaga: GLib.Object {

	public static int main (string[] args) {
		stdout.printf ("run usmsd!\n");

OpenSagaServer oSAGAServer = new OpenSagaServer();
//smsServer.ResetAndLoadDevices();
oSAGAServer.Run();

print("El servidor muere...");
		return 0;
	}




}





