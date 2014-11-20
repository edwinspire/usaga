//
//
//  Author:
//       Edwin De La Cruz <admin@edwinspire.com>
//
//  Copyright (c) 2011 edwinspire
//  Web Site http://edwinspire.com
//
//  Quito - Ecuador
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
using edwinspire.uSAGA;
public class RunuSaga: GLib.Object {
	public static int main (string[] args) {
		stdout.printf ("run usagad!\n");
		uSagaServer oSAGAServer = new uSagaServer();
		string Install_Directory = Environment.get_current_dir();
		
		if(args.length>1){
			Install_Directory = args[1];
		}else{
			
#if _LNX_SPIRE_
    	Install_Directory = "/opt/usaga";
#endif
			
		}
		
		oSAGAServer.runuSAGA(Install_Directory);
		
		print("El servidor muere...");
		return 0;
	}
}
