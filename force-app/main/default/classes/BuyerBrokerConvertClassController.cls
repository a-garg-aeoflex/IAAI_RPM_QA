public class BuyerBrokerConvertClassController{ 
    
    public BuyerBrokerConvertClassController(){
        
    }
 
    // This is our wrapper/container class. A container class is a class, a data structure, or an abstract data type whose instances are collections of other objects. In this example a wrapper class contains both the standard salesforce object Account and a Boolean value
    public class wrapBrokerClass {
        public String Buyer_ID{get; set;}
        public String Buyer_Name {get; set;}
       
        public String Address_Line_1{get; set;}
        public String City_Name{get; set;}
        public String Zip_Code{get; set;}
        public String State_Abbreviation{get; set;}
        public String County_Name {get; set;}
        public String Phone_Number_1{get; set;}
        public String Federal_Tax_ID {get; set;}
        public String Buyer_Type_Code {get; set;}
        public String Mail_Address_Line_1 {get; set;}
        public String Mail_City_Name{get; set;}
        public String Mail_Zip_Code{get; set;}
        public String Mail_State_Abbreviation {get; set;}
        public String Mail_Country_Abbreviation{get; set;}
        public String Home_Branch_Number{get; set;}
        public String Status_Code{get; set;}
        public String Primary_Contact_ID{get; set;}
        
        public List<wrapBuyer_Employee> lstEmployee;
 
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapBrokerClass (Account a) {
            
        }
    }
     public class wrapBuyer_Employee{
        public String Buyer_ID{get; set;}
        public String Buyer_Employee_ID {get; set;}
       
        public String Status_Code{get; set;}
        public String Job_Title_Code{get; set;}
        public String First_Name{get; set;}
        public String Last_Name{get; set;}
        public String Address1{get; set;}
        public String City{get; set;}
        public String State {get; set;}
        public String Country{get; set;}
        public String Zip{get; set;}
        public String Phone{get; set;}
        public String EMail_Address_1{get; set;}
        public String Contact_Type {get; set;}
        public String Middle_Initial{get; set;}
        public String User_ID{get; set;}
        public String Mobile_Phone_Number{get; set;}
        public String Salutation{get; set;}
        public String Gender{get; set;}
        public String Primary_Contact_Method_Code{get; set;}
        public String Birth_Date{get; set;}
        public String Language_Code{get; set;}
        
 
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapBuyer_Employee() {
            
        }
    }
}