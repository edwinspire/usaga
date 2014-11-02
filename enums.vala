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
namespace edwinspire.uSAGA {
	public enum EventType {
		Unknow,
		Alarm_Cancel,
		Alarm,
		Alarm_Restore,
		Trouble,
		Trouble_Restore,
		SMS_Alarm,		
		Medical_Alarm,
		Medical_Alarm_Restore,
		Medical_Trouble,
		Medical_Trouble_Restore,
		SMS_Medical,
		Perimeter_Alarm,
		Perimeter_Alarm_Restore,
		Perimeter_Trouble,
		Perimeter_Trouble_Restore,
		SMS_Perimeter,		
		Interior_Alarm,
		Interior_Alarm_Restore,
		Interior_Trouble,
		Interior_Trouble_Restore,		
		SMS_Interior,		
		Z24H_Alarm,
		Z24H_Alarm_Restore,
		Z24H_Trouble,
		Z24H_Trouble_Restore,		
		SMS_Z24H,
		Fire_Alarm,
		Fire_Alarm_Restore,
		Fire_Trouble,
		Fire_Trouble_Restore,
		SMS_Fire,
		Smoke_Alarm,
		Smoke_Alarm_Restore,
		Smoke_Trouble,
		Smoke_Trouble_Restore,
		SMS_Smoke,		
		Panic_Alarm,
		Panic_Alarm_Restore,
		Panic_Trouble,
		Panic_Trouble_Restore,
		SMS_Panic,			
		Tamper_Alarm,
		Tamper_Alarm_Restore,
		Tamper_Trouble,
		Tamper_Trouble_Restore,
		SMS_Tamper,
		Burglary_Alarm,
		Burglary_Alarm_Restore,
		Burglary_Trouble,
		Burglary_Trouble_Restore,
		SMS_Burglary,
		ACFail,
		ACRestore,
		BatteryLow,
		Battery_Restore,
		WeekyReport,
		WeekyReport_No_Received,
		PeriodicReport,
		PeriodicReport_No_Received,
		Entry_Unauthorized,
		Exit_Unauthorized,
		Entry_Undetected,
		Exit_Undetected,
		Request_Service, //-- Mantenimiento --
		System_Fail,
		SMS_Holdup,
		SMS_Earthquake,
		SMS_Violency,
		Alarm_Call_Phone,
		Alarm_Call_Phone_Mobile,
		SMS_Alarm_Silent,
		SMS_Message,
		ReceiverInformFromAccount,
		ReceiverInformFromGroup,
		Account_Edited,
		Account_Created,
		Account_Deleted,
		Account_Data_access,
		Account_User_New,
		Account_User_Edited,
		Account_User_Deleted,
		Account_Contact_New,
		Account_Contact_Edited,
		Account_Contact_Deleted,
		HearBeat_Receiver,
		System_Log,
		Task,
		Special_Event,
		Income_Security_Staff,
		Output_Security_Staff,
		Income_Security_Supervisor,
		Output_Security_Supervisor,
		Delivery_Equipment_Materials_Documents,
		Receipt_Equipment_Materials_Documents,
		Opening_Customer_Care,
		Close_Customer_Care,
		Start_Meeting,
		End_Meeting,
		Start_Holiday,
		End_Holiday,
		Income_Person,
		Output_Person,
		Equipment_Check,
		Reminder,
		Armed,
		Disarmed,
		Armed_Not_Received,
		Disarmed_Not_Received,
		Income_Vehicle,
		Output_Vehicle,
		Attempted_Kidnapping,
		Attempted_Theft,
		Attempted_Assault,
		The_Control_Panel_Does_Not_Send_Events,
		Suspicious_Person,
		Suspicious_Vehicle,
		Assault, 
		Theft,
		Installation,
		Uninstall
	}
	public enum EventStatus {
		Open,
			Pending,
			Finalized
	}
	public enum AccountType {
		Unknown,
			Home,
			Commercial,
			Financial
	}
	public enum ComunicationFormat {
		Unknown,
			SIA,
			ContactID
	}
}
