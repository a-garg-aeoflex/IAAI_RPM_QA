global class IAAI_VPEListing_Batch implements Database.Batchable<object>, Database.AllowsCallouts, Database.Stateful {
    global Set<String> processedPartners = new Set<String>();
    global Boolean updateCall;
    global String partnerName = 'CARVIO';
    global List<String> oldListing = new List<String>();
    global IAAI_VPEListing_Batch(Boolean value) {
        this.updateCall = value;
    }
    global List<object> start(Database.BatchableContext bc) {
        List<IAAI_VPE_Listing_Partner__mdt> records = [SELECT Id, DeveloperName, Authtoken__c, Endpoint__c FROM IAAI_VPE_Listing_Partner__mdt WHERE DeveloperName = 'CARVIO'];
        VPE_Listing_Partner__c partnerDetail = [SELECT Id, Name, Last_Batch_Ran_At__c, Call_Start_Time__c, Call_End_Time__c FROM VPE_Listing_Partner__c WHERE Name = 'CARVIO' LIMIT 1];
        List<jsonWrapper> jsonList = new List<jsonWrapper>();
        List<object> responseList = new List<object>();
        for( IAAI_VPE_Listing_Partner__mdt partner : records  ) {
            processedPartners.add(partner.DeveloperName);
            if( partner.DeveloperName == 'CARVIO' ) {
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setMethod('GET');
                req.setHeader('Authorization', partner.Authtoken__c);
                String since;
                if( partnerDetail.Last_Batch_Ran_At__c != null ) {
                    since = String.valueOf(partnerDetail.Last_Batch_Ran_At__c).replaceAll(' ','T');
                    if( updateCall == true ) {
                        req.setEndpoint(partner.Endpoint__c+'?has_changed=true');
                    } else {
                        req.setEndpoint(partner.Endpoint__c+'?since='+since);
                    }
                } else {
                    if( updateCall == true ) {
                        req.setEndpoint(partner.Endpoint__c+'?has_changed=true');
                    } else {
                        req.setEndpoint(partner.Endpoint__c);
                    }
                }
                HTTPResponse res = http.send(req);
                if( res.getStatusCode() == 200 ) {
                    jsonList = parse(res.getBody());
                }
            }
        }
        
        System.debug('Size-->'+jsonList.size());
        return jsonList;
    }
    global void execute(Database.BatchableContext bc, List<object> scope) {
        System.debug('records-->'+scope.size());
        List<jsonWrapper> payload = (List<jsonWrapper>) scope;
        VPE_Listing_Partner__c partnerDetail = [SELECT Id, Name, Last_Batch_Ran_At__c, Call_Start_Time__c, Call_End_Time__c FROM VPE_Listing_Partner__c WHERE Name = 'CARVIO' LIMIT 1];
       claim_values__mdt claimVal = [SELECT id, DeveloperName, value__c From claim_values__mdt Where DeveloperName =: partnerDetail.Name limit 1];
        if( scope.size() > 0 ) {
            Map<String, VPE_Listings__c> payloadListingMap = new Map<String, VPE_Listings__c>();
            List<VPE_Listings__c> listingNeedsStatusUpdate = new List<VPE_Listings__c>();
            for(jsonWrapper jW : payload){
                oldListing.add(jw.eid);
                VPE_Listings__c vp = new VPE_Listings__c();
                vp.Hyperlink__c= jw.lead_url;
                vp.claim__c = claimVal.DeveloperName;
                vp.Pick_Up_Window_1__c = jw.pickup_date_1;
                vp.Pickup_Address__c = jw.pickup_date_2;
                vp.Make__c= jw.make;
                
                if(jw.odometer != null && jw.odometer != '' ){
                    vp.Mileage__c= Decimal.valueof(jw.odometer.replaceAll(',',''));
                }
                vp.Model__c= jw.model;
                vp.Model_Year__c= jw.year;
                vp.Pickup_Zip__c= jw.zipcode;
                vp.Scheduled_Time_for_Auction__c= jw.createdAt;
                if( jw.images.size() > 0 ) {
                    vp.Vehicle_Image__c = jw.images[0];
                }
                vp.Notes__c = String.valueOf(jw.notes);
                vp.Status_of_Listing__c= jw.lead_status;
                vp.VIN__c= jw.vin;
                vp.Listing_Id__c= jw.eid;
                vp.Provider_First_Name__c = jw.first_name;
                vp.Provider_Last_Name__c = jw.last_name;
                vp.Provider_Phone_Number__c = jw.phone;
                vp.Pickup_Street__c = jw.pickup_street;
                vp.Original_Bid_Offer_Amount__c = jw.offer_amount;
                vp.Pickup_City__c = jw.pickup_city;
                vp.Pickup_State__c = jw.pickup_state;
                vp.Pickup_Zip__c = jw.pickup_zip;
                vp.Pickup_Address__c = jw.pickup_street+' '+jw.pickup_city+' '+jw.pickup_state+' '+jw.pickup_zip;
                vp.Pickup_Phone_Number__c = jw.pickup_phone;
                vp.Has_Keys__c = jw.has_keys;
                vp.VPE_Listing_Partner__c = partnerDetail.Id;
                if( updateCall == true ) {
                    vp.Blackbookupdated__c = false;
                }
                vp.Loss_Type_Code__c = jw.LossTypeCode;
                vp.Primary_Damage__c = jw.PrimaryDamage;
                vp.Secondary_Damage__c = jw.SecondaryDamage;
                vp.Engine_Status_Code__c = jw.EngineStatusCode;
                if(jw.VehicleConditionGrade != null ){
                	 vp.Vehicle_Condition_Grade__c = Integer.valueof(jw.VehicleConditionGrade);
                    payloadListingMap.put(vp.Listing_Id__c, vp);
                }
              
                
                
                
                
            }
            if( updateCall == false && payloadListingMap.values().size() > 0 ) {
                List<VPE_Listings__c> oldListingDetail = [SELECT Id, Status_of_Listing__c, Listing_Id__c FROM VPE_Listings__c WHERE Listing_Id__c IN :oldListing];
                if( oldListingDetail.size() > 0 ) {
                    for( VPE_Listings__c ovpl : oldListingDetail ) {
                        // Status Update only, if record exist in the system
                        if( payloadListingMap.containsKey(ovpl.Listing_Id__c) ) {
                            VPE_Listings__c ovp = payloadListingMap.get(ovpl.Listing_Id__c);
                            if( ovp.Status_of_Listing__c != ovpl.Status_of_Listing__c ) {
                                VPE_Listings__c needStatusUpdate = new VPE_Listings__c(Id=ovpl.Id);
                                needStatusUpdate.Status_of_Listing__c = ovp.Status_of_Listing__c;
                                needStatusUpdate.Blackbookupdated__c = false;
                                listingNeedsStatusUpdate.add(needStatusUpdate);
                            } 
                            payloadListingMap.remove(ovpl.Id);
                        }
                    }
                }
                if( listingNeedsStatusUpdate.size() > 0 ) {
                    update listingNeedsStatusUpdate;
                }
                if( payloadListingMap.values().size() > 0 ) {
                    upsert payloadListingMap.values() Listing_Id__c;
                }
            } 
            else if( updateCall == true && payloadListingMap.values().size() > 0 ) {
                upsert payloadListingMap.values() Listing_Id__c;
            }
        }
    }
    global void finish(Database.BatchableContext bc){ 
        if( processedPartners != null && processedPartners.size() > 0 ) {
            List<VPE_Listing_Partner__c> partnersToBeUpdate = [SELECT Id, Name, Last_Batch_Ran_At__c FROM VPE_Listing_Partner__c WHERE Name IN :processedPartners];
            if( processedPartners != null && processedPartners.size() > 0 ) {
                for(VPE_Listing_Partner__c partner : partnersToBeUpdate) {
                    partner.Last_Batch_Ran_At__c = System.Datetime.now();
                }
                update partnersToBeUpdate;
            }
        }
        if( updateCall != true ) {
            Database.executeBatch(new IAAI_VPEListing_Batch(true));
        } else {
            List<VPE_Listings__c> emptyVPEListing = new List<VPE_Listings__c>();
            if( !Test.isRunningTest() ) {
                Database.executeBatch(new IAAI_UpdateMarketValueBatch(emptyVPEListing), 100);
            	Database.executeBatch(new IAAI_Blackbook_Batch(), 10);
            }
        }
    }

    public static List<jsonWrapper> parse(String json){
        return (List<jsonWrapper>) System.JSON.deserialize(json, List<jsonWrapper>.class);
    }
    
    class jsonWrapper{
        public String eid;  //5d814023ed930c6d2858dd95
        public List<cls_notes> notes;
        public String listing_title;    //2015 2015 Hyundai Sonata Eco
        public String listing_price;    //9000.00
        public String name; //Ali
        public String phone;    //404-916-3649
        public String email;    //dev@carvio.com
        public String year; //2015
        public String make; //Hyundai
        public String model;    //Sonata Eco
        public String trim; //
        public String type; //Sedan
        public String odometer; //72,602
        public String engine;   //4 Cylinders
        public String drivetrain;   //Fwd
        public String fuel; //Gas
        public String trans;    //Automatic
        public String interior_color;   //
        public String exterior_color;   //Grey
        public String vin;  //5npe24aa0fh176041
        public String title;    //Clean
        public String sendEmail;    //false
        public String sendSMS;  //true
        public List<String> images; // array of images
        public String lead_status;  //hot_leads
        public String listing_date; //2019-09-17T16:20:52.762Z
        public String zipcode;
        public String guid; //880ok7oa
        public Decimal offer_amount;
        public String carfax;   //
        public Datetime createdAt;    //2019-09-17T20:20:51.134Z
        public String lead_url;
        public String first_name;
        public String last_name;
        public String pickup_phone;
        public String pickup_street;
        public String pickup_city;
        public String pickup_state;
        public String pickup_country;
        public string pickup_zip;
        public String has_keys;
        public String pickup_date_1;
        public String pickup_date_2;
        public String VehicleConditionGrade;
        public String LossTypeCode;
        public String PrimaryDamage;
        public String SecondaryDamage;
        public String EngineStatusCode;
        
    }
    class cls_notes {
        public String note; //7,125
        public String updatedAt; //9,000
    }
}