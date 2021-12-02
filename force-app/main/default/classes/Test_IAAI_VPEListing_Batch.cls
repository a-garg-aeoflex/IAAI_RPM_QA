@IsTest
private class Test_IAAI_VPEListing_Batch {
    @testSetup static void dataSetup() {
        VPE_Listing_Partner__c partner = new VPE_Listing_Partner__c();
        partner.Name = 'CARVIO';
        partner.Call_Frequency_Min__c = 2;
        partner.Cron_Id__c = 'test';
        partner.Call_Start_Time__c = System.now().time();
        partner.Call_End_Time__c = System.now().addMinutes(30).time();
        insert partner;

        List<VPE_Listings__c> listing = new List<VPE_Listings__c>();
        VPE_Listings__c vpl = new VPE_Listings__c();
        vpl.VIN__c = '1gth5cea0g1152730';
        vpl.Make__c = 'Gmc';
        vpl.Model__c = 'Canyon Extended Cab Sle';
        vpl.Model_Year__c = '2016';
        vpl.Listing_Id__c = '5e0e60ab384bf92e0d46dd3g';
        vpl.Mileage__c = 95250;
        vpl.Status_of_Listing__c = 'parked';
        vpl.Blackbookupdated__c = true;
        
        VPE_Listings__c vpl1 = new VPE_Listings__c();
        vpl1.VIN__c = '3kpfk4a70he136753';
        vpl1.Make__c = 'Gmc';
        vpl1.Model__c = 'Canyon Extended Cab Sle';
        vpl1.Model_Year__c = '2016';
        vpl1.Listing_Id__c = '5e0e6094384bf92e0d46dd3h';
        vpl1.Mileage__c = 95250;
        vpl1.Blackbookupdated__c = true;
        
        VPE_Listings__c vpl2 = new VPE_Listings__c();
        vpl2.VIN__c = '3kpfk4a70he136753';
        vpl2.Make__c = 'Gmc';
        vpl2.Model__c = 'Canyon Extended Cab Sle';
		vpl2.Blackbookupdated__c = true;
        vpl2.Model_Year__c = '2016';
        vpl2.Listing_Id__c = '5e0e6094384bf92e0d46dd31';
        vpl2.Mileage__c = 95250;
        
        listing.add(vpl);
        listing.add(vpl1);
        listing.add(vpl2);
        
        insert listing;
    }
    @IsTest static void testBatch() {
        Test.startTest();
        	String responseText = '[{"eid":"5e0e60ab384bf92e0d46dd33","VehicleConditionGrade":"3","LossTypeCode":"ot","listing_title":"2016 Gmc Canyon Extended Cab Sle","listing_price":"12490.00","year":"2016","make":"Gmc","model":"Canyon Extended Cab Sle","odometer":"95,250","vin":"1gth5cea0g1152730","title":"Lien","lead_status":"parked","images":["https://images.craigslist.org/01414_bEFqm8x1Kgq_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"9,125","good":"10,850","excellent":"12,550"},"createdAt":"2020-01-02T21:29:15.618Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e60ab384bf92e0d46dd33","notes":[]},{"eid":"5e0e6094384bf92e0d46dd31","listing_title":"2017 Kia Forte Lx 4d","listing_price":"9650.00","year":"2017","make":"Kia","model":"Forte Lx 4d","odometer":"5,000","vin":"3kpfk4a70he136753","title":"Clean","lead_status":"parked","images":["https://images.craigslist.org/00303_56DjggWycOt_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"10,450","good":"11,650","excellent":"12,850"},"createdAt":"2020-01-02T21:28:52.390Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e6094384bf92e0d46dd31","notes":[]}]';
        	Mock_IAAI_VPEListing_Batch fakeResponse = new Mock_IAAI_VPEListing_Batch(200, 'Complete', responseText, null);
        	Test.setMock(HttpCalloutMock.class, fakeResponse);
			Database.executeBatch(new IAAI_VPEListing_Batch(false));
        Test.stopTest();
        List<VPE_Listings__c> vpeList = [SELECT Id FROM VPE_Listings__c];
		VPE_Listings__c vpeListStatus = [SELECT Id, Status_of_Listing__c FROM VPE_Listings__c WHERE Listing_Id__c = '5e0e6094384bf92e0d46dd31' LIMIT 1];
        System.assertEquals(4, vpeList.size());
        //System.assertEquals('Parked', vpeListStatus.Status_of_Listing__c);
    }
    @IsTest
    static void testForScheduler () { 
        Test.StartTest();
        	VPE_Listing_Partner__c partnerDetail = [SELECT Id, Cron_Id__c FROM VPE_Listing_Partner__c WHERE Name = 'CARVIO' limit 1];
        	String responseText = '[{"_id":"5e5189f202482439d666bc71","VehicleConditionGrade":"3","LossTypeCode":"ot", "listing_title":"2002 2002 Honda Civic Ex","listing_price":"3000.00","year":"2002","make":"Honda","model":"Civic Ex","odometer":"","vin":"1hgem21932l083249","title":"Clean","lead_status":"parked","images":["https://images.craigslist.org/00O0O_fN4OJnW0vbn_600x450.jpg","https://images.craigslist.org/00e0e_lg1bVQoPsP4_600x450.jpg","https://images.craigslist.org/00C0C_ktctZVTWh3p_600x450.jpg","https://images.craigslist.org/00S0S_ogASIhVhKC_600x450.jpg","https://images.craigslist.org/00D0D_2NL1GS1IJik_600x450.jpg","https://images.craigslist.org/00T0T_2xMFNvAjmbF_600x450.jpg","https://images.craigslist.org/00S0S_ogASIhVhKC_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"325","good":"825","excellent":"1,325"},"createdAt":"2020-02-22T20:07:14.314Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e5189f202482439d666bc71","zipcode":null,"notes":[]},{"_id":"5e51887402482439d666bc6b","listing_title":"2006 Toyota Corolla Le","listing_price":"4500.00","year":"2006","make":"Toyota","model":"Corolla Le","odometer":"82,796","vin":"1nxbr32e06z579707","title":"Clean","lead_status":"parked","images":["https://images.craigslist.org/01313_ivH6sddbnDo_600x450.jpg","https://images.craigslist.org/00101_aC4q6gYB1H7_600x450.jpg","https://images.craigslist.org/00V0V_aW1al74jbLN_600x450.jpg","https://images.craigslist.org/00101_gdzzZ0kpGw4_600x450.jpg","https://images.craigslist.org/00a0a_lxOdTRtKq7j_600x450.jpg","https://images.craigslist.org/00Z0Z_jmw999OufyZ_600x450.jpg","https://images.craigslist.org/00000_d7S0TH4Gay6_600x450.jpg","https://images.craigslist.org/00u0u_c7enbKDRRky_600x450.jpg","https://images.craigslist.org/01414_8eaSeckZP2t_600x450.jpg","https://images.craigslist.org/00202_d3SbLIU423M_600x450.jpg","https://images.craigslist.org/00B0B_iSA3zlBeRBQ_600x450.jpg","https://images.craigslist.org/00202_fTKBOCBmjxK_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"2,100","good":"2,650","excellent":"3,200"},"createdAt":"2020-02-22T20:00:52.350Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e51887402482439d666bc6b","zipcode":null,"notes":[]},{"_id":"5e0e60ab384bf92e0d46dd33","listing_title":"2016 Gmc Canyon Extended Cab Sle","listing_price":"12490.00","year":"2016","make":"Gmc","model":"Canyon Extended Cab Sle","odometer":"95,251","vin":"1gth5cea0g1152730","title":"Lien","lead_status":"closing","images":"https://images.craigslist.org/01414_bEFqm8x1Kgq_600x450.jpg,https://images.craigslist.org/00808_9awmhV9AjD7_600x450.jpg,https://images.craigslist.org/00W0W_jBbFNaLbgQz_600x450.jpg","lead_owner":"IAAI","has_changed":"true","mmrActual":{"fair":"9,125","good":"10,850","excellent":"12,550"},"createdAt":"2020-01-02T21:29:15.618Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e60ab384bf92e0d46dd33","updatedAt":"2020-02-21T21:40:48.435Z","offer_amount":"6000.56","offer_consignment":"0","zipcode":null,"notes":[]},{"_id":"5e0e6094384bf92e0d46dd31","listing_title":"2017 Kia Forte Lx 4d","listing_price":"9650.00","year":"2017","make":"Kia","model":"Forte Lx 4d","odometer":"5,000","vin":"3kpfk4a70he136753","title":"Clean","lead_status":"won","images":["https://images.craigslist.org/00303_56DjggWycOt_600x450.jpg","https://images.craigslist.org/00K0K_aSxtDCdul2c_600x450.jpg","https://images.craigslist.org/00p0p_fuhRvoqVBoO_600x450.jpg","https://images.craigslist.org/00f0f_3SrpRR1tkO9_600x450.jpg","https://images.craigslist.org/00X0X_2oj7Ebub8X3_600x450.jpg","https://images.craigslist.org/01515_1ypTWLnrgAM_600x450.jpg","https://images.craigslist.org/00Z0Z_b0CuHdejPqw_600x450.jpg","https://images.craigslist.org/00J0J_dAwstZxMo0i_600x450.jpg","https://images.craigslist.org/00T0T_i4ajcLv1FOX_600x450.jpg","https://images.craigslist.org/00202_fTdeiQN74Yq_600x450.jpg","https://images.craigslist.org/00303_66Xfvm709M8_600x450.jpg","https://images.craigslist.org/00S0S_lLExWXcfsjs_600x450.jpg","https://images.craigslist.org/00P0P_BvOJvdVcYH_600x450.jpg","https://images.craigslist.org/00u0u_8T6oP5b4RTN_600x450.jpg","https://images.craigslist.org/00d0d_f13qYooAFG0_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"10,450","good":"11,650","excellent":"12,850"},"createdAt":"2020-01-02T21:28:52.390Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e6094384bf92e0d46dd31","zipcode":null,"notes":[]},{"_id":"5e0e6088384bf92e0d46dd2b","listing_title":"2002 Chevy Silverado","listing_price":"9500.00","year":"2002","make":"Chevrolet","model":"Silverado","odometer":"111224","vin":"1gchk23u32f158498","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00i0i_ic2YxFr6rFC_600x450.jpg","https://images.craigslist.org/00u0u_8NdSqLXZTRp_600x450.jpg","https://images.craigslist.org/00505_hGsbL9vEvcY_600x450.jpg","https://images.craigslist.org/01010_hpsaP1ScDcD_600x450.jpg","https://images.craigslist.org/00q0q_dysVmVMUiKV_600x450.jpg","https://images.craigslist.org/00z0z_gddTu6qXkh5_600x450.jpg","https://images.craigslist.org/00p0p_cX8A00fSHDu_600x450.jpg","https://images.craigslist.org/00P0P_YgYLd7QGKo_600x450.jpg","https://images.craigslist.org/00b0b_hE4hczizIYA_600x450.jpg","https://images.craigslist.org/00303_f4kDg8Q9jYs_600x450.jpg","https://images.craigslist.org/01313_evZ0jI3tHIM_600x450.jpg","https://images.craigslist.org/01616_gxCoMbtNC9t_600x450.jpg","https://images.craigslist.org/00B0B_rAqN57JmGQ_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"2,875","good":"4,325","excellent":"5,775"},"createdAt":"2020-01-02T21:28:40.150Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e6088384bf92e0d46dd2b","updatedAt":"2020-02-21T13:52:01.991Z","zipcode":null,"notes":[]},{"_id":"5e0e607d384bf92e0d46dd25","listing_title":"2000 Bmw 528i","listing_price":"4300.00","year":"2000","make":"Bmw","model":"528i","odometer":"145,004","vin":"Wbadm6342ygu14002","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00W0W_1bNEAr7uXAH_600x450.jpg","https://images.craigslist.org/00m0m_ayFk5rDHQLs_600x450.jpg","https://images.craigslist.org/01212_5eo4bt92eta_600x450.jpg","https://images.craigslist.org/00303_fOyLrY73VpH_600x450.jpg","https://images.craigslist.org/00p0p_jP3go0rqmYx_600x450.jpg","https://images.craigslist.org/00404_badBLX2YwE4_600x450.jpg","https://images.craigslist.org/00d0d_5TQ6zLTVIw4_600x450.jpg","https://images.craigslist.org/00n0n_8Sw3QTkWwfR_600x450.jpg","https://images.craigslist.org/01313_5utrVMqsr3Y_600x450.jpg","https://images.craigslist.org/00i0i_dyIeKwX1cuA_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"350","good":"950","excellent":"1,550"},"createdAt":"2020-01-02T21:28:29.851Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e607d384bf92e0d46dd25","updatedAt":"2020-02-21T13:52:01.994Z","zipcode":null,"notes":[]},{"_id":"5e0e6063384bf92e0d46dd23","listing_title":"2012 2012chevrolet Cruze Lt","listing_price":"","year":"2012","make":"","model":"Chevrolet Cruze Lt","odometer":"137,674","vin":"1g1pg5sc4c7107491","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00r0r_gSlfE6JCq8j_600x450.jpg","https://images.craigslist.org/00606_eLsscCOFw2x_600x450.jpg","https://images.craigslist.org/00n0n_9SVkxjKkCtX_600x450.jpg","https://images.craigslist.org/00y0y_2EeaPw0eDFw_600x450.jpg","https://images.craigslist.org/00n0n_fA9qlT5zS9V_600x450.jpg","https://images.craigslist.org/00h0h_ckBUc7yZ2Yv_600x450.jpg","https://images.craigslist.org/00W0W_5knWNmqluGH_600x450.jpg","https://images.craigslist.org/00U0U_aJp4vIGWL0G_600x450.jpg","https://images.craigslist.org/00u0u_12TJ6HaXR39_600x450.jpg","https://images.craigslist.org/00d0d_g5auAxEL5BT_600x450.jpg","https://images.craigslist.org/00e0e_3AsFEmv887T_600x450.jpg","https://images.craigslist.org/00G0G_15KsEkREf25_600x450.jpg","https://images.craigslist.org/00A0A_e9ZMqPOzg05_600x450.jpg","https://images.craigslist.org/00101_bxrAHHzchFM_600x450.jpg","https://images.craigslist.org/00q0q_ivvcDWWfQyC_600x450.jpg","https://images.craigslist.org/00u0u_98PZuuNMAlF_600x450.jpg","https://images.craigslist.org/00U0U_f6AlRxQAmSV_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"1,450","good":"2,550","excellent":"3,650"},"createdAt":"2020-01-02T21:28:03.494Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e6063384bf92e0d46dd23","updatedAt":"2020-02-21T13:52:01.995Z","zipcode":null,"notes":[]},{"_id":"5e0e6054384bf92e0d46dd1d","listing_title":"2017 Land Rover Range Rover Sport","listing_price":"69500.00","year":"2017","make":"","model":"Land Rover Range Rover Sport","odometer":"19,800","vin":"Salwv2fexha131204","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00O0O_fuNr2AiKH5i_600x450.jpg","https://images.craigslist.org/00o0o_1rVuMCn87I6_600x450.jpg","https://images.craigslist.org/00Z0Z_bLHlubBt8aE_600x450.jpg","https://images.craigslist.org/00303_2wH58Fp8Ju3_600x450.jpg","https://images.craigslist.org/00G0G_gCxdrBjD458_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"58,300","good":"61,400","excellent":"64,500"},"createdAt":"2020-01-02T21:27:48.207Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e6054384bf92e0d46dd1d","updatedAt":"2020-02-21T13:52:01.995Z","zipcode":null,"notes":[]},{"_id":"5e0e604b384bf92e0d46dd17","listing_title":"2004 Dodge Ram 1500 Quad Cab","listing_price":"6000.00","year":"2004","make":"Ram","model":"Dodge  1500 Quad Cab","odometer":"128,944","vin":"1d7ha18d04s723506","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00202_cgWt1iC8oIF_600x450.jpg","https://images.craigslist.org/00i0i_6akrPkqFnPv_600x450.jpg","https://images.craigslist.org/00O0O_bc0xaSXK41G_600x450.jpg","https://images.craigslist.org/00j0j_hpyL49bHbhD_600x450.jpg","https://images.craigslist.org/00505_luCqupKXyf_600x450.jpg","https://images.craigslist.org/00303_95CnI1cKt2m_600x450.jpg","https://images.craigslist.org/00J0J_9k1mCHwdrV3_600x450.jpg","https://images.craigslist.org/00r0r_iJfHVnEmyce_600x450.jpg","https://images.craigslist.org/00707_7xKbmwTpqSK_600x450.jpg","https://images.craigslist.org/00a0a_2QgD9eMEpwV_600x450.jpg","https://images.craigslist.org/00F0F_4JCRDBUIIuQ_600x450.jpg","https://images.craigslist.org/00u0u_dMlSEQiB0ME_600x450.jpg","https://images.craigslist.org/00F0F_bvAqjdwUjzk_600x450.jpg","https://images.craigslist.org/00707_5FLVN4e6md8_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"2,850","good":"4,075","excellent":"5,300"},"createdAt":"2020-01-02T21:27:39.986Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e604b384bf92e0d46dd17","updatedAt":"2020-02-21T13:52:01.996Z","zipcode":null,"notes":[]},{"_id":"5e0e6044384bf92e0d46dd11","listing_title":"2017 Chevrolet Volt Premier","listing_price":"19900.00","year":"2017","make":"Chevrolet","model":"Volt Premier","odometer":"52,500","vin":"1g1rd6s51hu104162","title":"Lien","lead_status":"closed","images":["https://images.craigslist.org/00z0z_4Ni5dRDt6VZ_600x450.jpg","https://images.craigslist.org/00b0b_3WcCe40pcuq_600x450.jpg","https://images.craigslist.org/00f0f_fV19swGslzW_600x450.jpg","https://images.craigslist.org/00X0X_iBxBY06yumQ_600x450.jpg","https://images.craigslist.org/01616_kumMXh6JXJi_600x450.jpg","https://images.craigslist.org/00W0W_hVR0Po80V3R_600x450.jpg","https://images.craigslist.org/01010_cjUEVPmSOsW_600x450.jpg","https://images.craigslist.org/00M0M_jMaecdvD7Wb_600x450.jpg","https://images.craigslist.org/00101_5cwLe6EpKKC_600x450.jpg","https://images.craigslist.org/00t0t_gIGfYoqsTvp_600x450.jpg","https://images.craigslist.org/00u0u_1Bxqld3G7eE_600x450.jpg","https://images.craigslist.org/00J0J_aZOFXrQedic_600x450.jpg","https://images.craigslist.org/00606_16GR0ZshW3H_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"13,000","good":"14,600","excellent":"16,150"},"createdAt":"2020-01-02T21:27:32.180Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e6044384bf92e0d46dd11","updatedAt":"2020-02-21T13:52:01.996Z","zipcode":null,"notes":[]},{"_id":"5e0e601d384bf92e0d46dd0b","listing_title":"2016 Ford Mustang Convertible","listing_price":"17999.00","year":"2016","make":"Ford","model":"Mustang Convertible","odometer":"42,000","vin":"1fatp8uh5g5243071","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00606_jRInsik8w1W_600x450.jpg","https://images.craigslist.org/00M0M_19epxCFW4Bz_600x450.jpg","https://images.craigslist.org/00p0p_b1yaJI6HIcS_600x450.jpg","https://images.craigslist.org/00G0G_cUs7K7VYgCG_600x450.jpg","https://images.craigslist.org/01111_ibdjj5nxsWD_600x450.jpg","https://images.craigslist.org/01212_iZ3S3C1u8bs_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"12,500","good":"15,100","excellent":"17,700"},"createdAt":"2020-01-02T21:26:53.604Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e601d384bf92e0d46dd0b","updatedAt":"2020-02-21T13:52:01.997Z","zipcode":null,"notes":[]},{"_id":"5e0e5ffe384bf92e0d46dd05","listing_title":"2010 Merecedes Benz Glk","listing_price":"8800.00","year":"2010","make":"","model":"Merecedes Benz Glk","odometer":"","vin":"Wdcgg5gb6af511431","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00M0M_at2oMHaQDZU_600x450.jpg","https://images.craigslist.org/00505_2vIPI56Qf4G_600x450.jpg","https://images.craigslist.org/00404_ckI620YVZqZ_600x450.jpg","https://images.craigslist.org/00n0n_9vk7eD4mM4C_600x450.jpg","https://images.craigslist.org/00o0o_bQmMPbIKBKb_600x450.jpg","https://images.craigslist.org/00v0v_7ZFWG5w1Qg9_600x450.jpg","https://images.craigslist.org/01515_j4f7yIPAau1_600x450.jpg","https://images.craigslist.org/01616_hDcEeUHl7Xm_600x450.jpg","https://images.craigslist.org/00202_cEau5v22aMC_600x450.jpg","https://images.craigslist.org/00R0R_gMdohF5FXwa_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"4,425","good":"6,050","excellent":"7,650"},"createdAt":"2020-01-02T21:26:22.451Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e5ffe384bf92e0d46dd05","updatedAt":"2020-02-21T13:52:01.997Z","zipcode":null,"notes":[]},{"_id":"5e0e5fc8384bf92e0d46dcff","listing_title":"2014 S550","listing_price":"39900.00","year":"2014","make":"","model":"S550","odometer":"29,000","vin":"Wddug8cbxea025522","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00I0I_9QjLEEFlNWM_600x450.jpg","https://images.craigslist.org/01515_2DWL89pB8V9_600x450.jpg","https://images.craigslist.org/00R0R_lUkWwZ3ipV5_600x450.jpg","https://images.craigslist.org/00q0q_1d98JmEQZqv_600x450.jpg","https://images.craigslist.org/00D0D_iryOEeu8y8Y_600x450.jpg","https://images.craigslist.org/01717_gqyxQUdYGR3_600x450.jpg","https://images.craigslist.org/00v0v_gFODELGrMor_600x450.jpg","https://images.craigslist.org/00101_gDALEA0H3vO_600x450.jpg","https://images.craigslist.org/00h0h_aE7EjPOu9gT_600x450.jpg","https://images.craigslist.org/00z0z_1n5eHhev6cE_600x450.jpg","https://images.craigslist.org/00404_jfFb9HE5kOp_600x450.jpg","https://images.craigslist.org/00C0C_cTi1udPahza_600x450.jpg","https://images.craigslist.org/00606_f39ibzJcOZe_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"30,700","good":"35,600","excellent":"40,400"},"createdAt":"2020-01-02T21:25:28.090Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e5fc8384bf92e0d46dcff","updatedAt":"2020-02-21T13:52:01.998Z","zipcode":null,"notes":[]},{"_id":"5e0e5f22384bf92e0d46dcf9","listing_title":"2017 Fiat 500x","listing_price":"16499.00","year":"2017","make":"Fiat","model":"500x","odometer":"21,500","vin":"Zfbcfxab1hp628353","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/01111_2tBi9njSmK6_600x450.jpg","https://images.craigslist.org/00S0S_a0XCa2W1raa_600x450.jpg","https://images.craigslist.org/00T0T_4S4D0qn4unE_600x450.jpg","https://images.craigslist.org/00D0D_hmr8AfRkbjG_600x450.jpg","https://images.craigslist.org/00Z0Z_h6ndkHCsfgW_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"8,225","good":"10,800","excellent":"13,350"},"createdAt":"2020-01-02T21:22:42.991Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e5f22384bf92e0d46dcf9","updatedAt":"2020-02-21T13:52:01.998Z","zipcode":null,"notes":[]},{"_id":"5e0e5f0d384bf92e0d46dcf3","listing_title":"2008 2008 Volkswagen Jetta S Sedan 4d","listing_price":"3650.00","year":"2008","make":"Volkswagen","model":"Jetta S Sedan 4d","odometer":"110,000","vin":"3vwjm71k78m114178","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00X0X_8ltxRzLbsYb_600x450.jpg","https://images.craigslist.org/01515_78eHSKYFsrh_600x450.jpg","https://images.craigslist.org/01111_6mrTqnxOvEV_600x450.jpg","https://images.craigslist.org/00B0B_3dW1NfutkAA_600x450.jpg","https://images.craigslist.org/00V0V_g5XNcVn8uAu_600x450.jpg","https://images.craigslist.org/00r0r_iBvZrMftfJn_600x450.jpg","https://images.craigslist.org/00r0r_9qbx2NXv2i5_600x450.jpg","https://images.craigslist.org/01010_dDvxow4cpIn_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"1,100","good":"1,550","excellent":"2,000"},"createdAt":"2020-01-02T21:22:21.635Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e5f0d384bf92e0d46dcf3","updatedAt":"2020-02-21T13:52:01.999Z","zipcode":null,"notes":[]},{"_id":"5e0e5f01384bf92e0d46dced","listing_title":"2007 Dodge Caliber","listing_price":"2000.00","year":"2007","make":"Dodge","model":"Caliber","odometer":"190,200","vin":"1b3hb28b87d511555","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00606_fa2SkcCE8i9_600x450.jpg","https://images.craigslist.org/01010_4SNTdEMme7D_600x450.jpg","https://images.craigslist.org/00V0V_cmSluvI8hUZ_600x450.jpg","https://images.craigslist.org/00j0j_9WGjnxuC02F_600x450.jpg","https://images.craigslist.org/00R0R_4jWjhA3cy34_600x450.jpg","https://images.craigslist.org/00s0s_7CY5w4qffBO_600x450.jpg","https://images.craigslist.org/00w0w_kGN9twmQeN2_600x450.jpg","https://images.craigslist.org/00e0e_93AWEYuNI2h_600x450.jpg","https://images.craigslist.org/00w0w_3UhpoON8Ue6_600x450.jpg","https://images.craigslist.org/00I0I_bdHtlkC0C06_600x450.jpg","https://images.craigslist.org/00D0D_g915Bt94Xaa_600x450.jpg","https://images.craigslist.org/01313_ilDP94U1sMN_600x450.jpg","https://images.craigslist.org/00O0O_cyWuhcTsJRi_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"325","good":"725","excellent":"1,125"},"createdAt":"2020-01-02T21:22:09.799Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e5f01384bf92e0d46dced","updatedAt":"2020-02-21T13:52:01.999Z","zipcode":null,"notes":[]},{"_id":"5e0e5ea8f0f58538f79aa232","listing_title":"2000 Chevrolet Astro Van","listing_price":"2000.00","year":"2000","make":"Chevrolet","model":"Astro Van","odometer":"148,500","vin":"1gnel19w7yb192115","title":"Clean","lead_status":"closed","images":["https://staging-pipeline.carvio.com/images/cvo_00y0yhgRckrCypZj.jpg","https://staging-pipeline.carvio.com/images/cvo_00J0JaZSrmtIGRC9.jpg","https://staging-pipeline.carvio.com/images/cvo_00h0hd6XhGGf4vUj.jpg","https://staging-pipeline.carvio.com/images/cvo_002021h6Lyv43vBC.jpg","https://staging-pipeline.carvio.com/images/cvo_00c0c7lYE4fMSiXP.jpg","https://staging-pipeline.carvio.com/images/cvo_01010h0j2mAPnAeS.jpg","https://staging-pipeline.carvio.com/images/cvo_00w0waIILUFCrLn4.jpg","https://staging-pipeline.carvio.com/images/cvo_00R0R1wFICfzd0qW.jpg"],"lead_owner":"IAAI","mmrActual":{"fair":"350","good":"1,200","excellent":"2,025"},"createdAt":"2019-12-31T14:54:06.358Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0b610ebb3ce47667d805b6","has_changed":false,"updatedAt":"2020-02-21T13:52:02.000Z","zipcode":null,"notes":[]},{"_id":"5e0e5db3384bf92e0d46dce7","listing_title":"2005 Toyota Corolla","listing_price":"2900.00","year":"2005","make":"Toyota","model":"Corolla","odometer":"172,767","vin":"1nxbr32e25z362142","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00R0R_9YZRF1JIqgm_600x450.jpg","https://images.craigslist.org/01616_jcrQZp1P6Wm_600x450.jpg","https://images.craigslist.org/00E0E_8RcpQdoXXoy_600x450.jpg","https://images.craigslist.org/00808_8vKIEymurC0_600x450.jpg","https://images.craigslist.org/00L0L_8l8b4pM6Er_600x450.jpg","https://images.craigslist.org/00J0J_1jJbDmclHWx_600x450.jpg","https://images.craigslist.org/00n0n_j53JVjmbbo6_600x450.jpg","https://images.craigslist.org/00j0j_gdSDnyoEmkU_600x450.jpg"],"lead_owner":"IAAI","has_changed":false,"mmrActual":{"fair":"1,650","good":"2,350","excellent":"3,050"},"createdAt":"2020-01-02T21:16:35.918Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0e5db3384bf92e0d46dce7","updatedAt":"2020-02-21T13:52:02.000Z","zipcode":null,"notes":[]},{"_id":"5e0b612fbb3ce47667d805c2","listing_title":"2014 2014 Toyota Camry Hybrid","listing_price":"","year":"2014","make":"Toyota","model":"Camry Hybrid","odometer":"128,745","vin":"4t1bd1fk5eu127981","title":"Clean","lead_status":"closed","images":["https://staging-pipeline.carvio.com/images/cvo_00505dKvEn8D0Of1.jpg","https://staging-pipeline.carvio.com/images/cvo_00U0Uedy4u1og77w.jpg","https://staging-pipeline.carvio.com/images/cvo_00z0z2xjx4wSMBMw.jpg","https://staging-pipeline.carvio.com/images/cvo_017178l0S7E5XdMw.jpg","https://staging-pipeline.carvio.com/images/cvo_00101lPYVZ7X78TD.jpg","https://staging-pipeline.carvio.com/images/cvo_00l0laPa2nls2INI.jpg","https://staging-pipeline.carvio.com/images/cvo_00V0Vh5cSCmMaUvN.jpg","https://staging-pipeline.carvio.com/images/cvo_00505ej5v40HqOYV.jpg","https://staging-pipeline.carvio.com/images/cvo_00W0W4fjjgSiJ3CO.jpg"],"lead_owner":"IAAI","mmrActual":{"fair":"4,125","good":"4,925","excellent":"5,725"},"createdAt":"2019-12-31T14:54:39.789Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0b612fbb3ce47667d805c2","updatedAt":"2020-02-21T13:52:02.000Z","has_changed":false,"zipcode":null,"notes":[{"note":"test","updatedAt":"2020-01-02T18:24:56.951Z"}]},{"_id":"5e0b6127bb3ce47667d805be","listing_title":"2000 Lexus Es 300","listing_price":"1500.00","year":"2000","make":"Lexus","model":"Es 300","odometer":"50,000","vin":"Jt8bf28g7y5086893","title":"Clean","lead_status":"closed","images":["https://staging-pipeline.carvio.com/images/cvo_00C0C59txFHVarFs.jpg","https://staging-pipeline.carvio.com/images/cvo_00f0f3pL1cUM6Yor.jpg","https://staging-pipeline.carvio.com/images/cvo_00y0ykyNHDy0iGGO.jpg","https://staging-pipeline.carvio.com/images/cvo_00202aDG2FUIsBl.jpg","https://staging-pipeline.carvio.com/images/cvo_00303ihTXZF8hJ6a.jpg","https://staging-pipeline.carvio.com/images/cvo_00g0g9MdpcMqOcpW.jpg","https://staging-pipeline.carvio.com/images/cvo_00i0ieCaWeRYvvhv.jpg"],"lead_owner":"IAAI","mmrActual":{"fair":"675","good":"1,225","excellent":"1,775"},"createdAt":"2019-12-31T14:54:31.919Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0b6127bb3ce47667d805be","updatedAt":"2020-02-21T13:52:02.001Z","has_changed":false,"zipcode":null,"notes":[]},{"_id":"5e0b6121bb3ce47667d805ba","listing_title":"2006 Dodge Ram 1500","listing_price":"3900.00","year":"2006","make":"Ram","model":"Dodge  1500","odometer":"151,001","vin":"1d7hu18276s647453","title":"Clean","lead_status":"closed","images":["https://staging-pipeline.carvio.com/images/cvo_009093Mq0pjIR34k.jpg","https://staging-pipeline.carvio.com/images/cvo_00w0wgsyMQsx6ic5.jpg","https://staging-pipeline.carvio.com/images/cvo_00Q0Q46hUpc87OlZ.jpg","https://staging-pipeline.carvio.com/images/cvo_00I0I7VDNEt8jxwz.jpg","https://staging-pipeline.carvio.com/images/cvo_00505lhQCbIVcOc8.jpg","https://staging-pipeline.carvio.com/images/cvo_00e0ecCiuzpxh8RU.jpg","https://staging-pipeline.carvio.com/images/cvo_00o0o6V4SjmxDAGN.jpg"],"lead_owner":"IAAI","mmrActual":{"fair":"1,900","good":"3,625","excellent":"5,350"},"createdAt":"2019-12-31T14:54:25.011Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0b6121bb3ce47667d805ba","updatedAt":"2020-02-21T13:52:02.002Z","has_changed":false,"zipcode":null,"notes":[]},{"_id":"5e0b610ebb3ce47667d805b6","listing_title":"2000 Chevrolet Astro Van","listing_price":"2000.00","year":"2000","make":"Chevrolet","model":"Astro Van","odometer":"148,500","vin":"1gnel19w7yb192115","title":"Clean","lead_status":"closed","images":["https://staging-pipeline.carvio.com/images/cvo_00y0yhgRckrCypZj.jpg","https://staging-pipeline.carvio.com/images/cvo_00J0JaZSrmtIGRC9.jpg","https://staging-pipeline.carvio.com/images/cvo_00h0hd6XhGGf4vUj.jpg","https://staging-pipeline.carvio.com/images/cvo_002021h6Lyv43vBC.jpg","https://staging-pipeline.carvio.com/images/cvo_00c0c7lYE4fMSiXP.jpg","https://staging-pipeline.carvio.com/images/cvo_01010h0j2mAPnAeS.jpg","https://staging-pipeline.carvio.com/images/cvo_00w0waIILUFCrLn4.jpg","https://staging-pipeline.carvio.com/images/cvo_00R0R1wFICfzd0qW.jpg"],"lead_owner":"IAAI","mmrActual":{"fair":"350","good":"1,200","excellent":"2,025"},"createdAt":"2019-12-31T14:54:06.358Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e0b610ebb3ce47667d805b6","has_changed":false,"updatedAt":"2020-02-21T13:52:02.003Z","zipcode":null,"notes":[]},{"_id":"5e063682e2f02458a70ab8d3","listing_title":"2001 Saturn","listing_price":"1450.00","year":"2001","make":"Saturn","model":"","odometer":"203,500","vin":"1g8zh52891z279343","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00R0R_aX9wkmEwoQs_600x450.jpg","https://images.craigslist.org/00M0M_ktRfhImEjWh_600x450.jpg","https://images.craigslist.org/00d0d_kLcvp5GY9Bd_600x450.jpg","https://images.craigslist.org/01515_30hbuyqicfn_600x450.jpg","https://images.craigslist.org/00W0W_9DzGR1zdUqB_600x450.jpg","https://images.craigslist.org/01717_aGJs5ACH4wL_600x450.jpg","https://images.craigslist.org/01111_4cc7G9PL8Mz_600x450.jpg","https://images.craigslist.org/00o0o_itbCkr0q7jg_600x450.jpg","https://images.craigslist.org/00E0E_2HeGfIHP6C8_600x450.jpg"],"lead_owner":"IAAI","mmrActual":{"fair":"100","good":"325","excellent":"575"},"createdAt":"2019-12-27T16:51:14.381Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e063682e2f02458a70ab8d3","has_changed":false,"updatedAt":"2020-02-21T13:52:02.003Z","zipcode":null,"notes":[]},{"_id":"5e063646e2f02458a70ab8cd","listing_title":"2004 Volkswagen Jetta Gls","listing_price":"3900.00","year":"2004","make":"Volkswagen","model":"Jetta Gls","odometer":"166,000","vin":"3vwsk69m34m041279","title":"Clean","lead_status":"closed","images":["https://images.craigslist.org/00n0n_kns2LANCqkc_600x450.jpg","https://images.craigslist.org/01111_1GH6qjV37vi_600x450.jpg","https://images.craigslist.org/00505_9pscRIpmkFM_600x450.jpg","https://images.craigslist.org/00L0L_94nGEnPPLp1_600x450.jpg","https://images.craigslist.org/00L0L_94nGEnPPLp1_600x450.jpg","https://images.craigslist.org/00c0c_ej8nG15l8rW_600x450.jpg","https://images.craigslist.org/00o0o_5W2wzNEVQSI_600x450.jpg","https://images.craigslist.org/00j0j_lBlilx7hy86_600x450.jpg","https://images.craigslist.org/00x0x_1Hj3EKXuiIW_600x450.jpg","https://images.craigslist.org/00b0b_6z86uloVJbu_600x450.jpg","https://images.craigslist.org/00l0l_cD8DDAF3EXU_600x450.jpg","https://images.craigslist.org/00l0l_cD8DDAF3EXU_600x450.jpg","https://images.craigslist.org/00e0e_6LS3OgjqKoZ_600x450.jpg"],"lead_owner":"IAAI","mmrActual":{"fair":"350","good":"700","excellent":"1,050"},"createdAt":"2019-12-27T16:50:14.694Z","lead_url":"https://staging-pipeline.carvio.com/deal/5e063646e2f02458a70ab8cd","has_changed":false,"updatedAt":"2020-02-21T13:52:02.005Z","zipcode":null,"notes":[]}]';
        	Mock_IAAI_VPEListing_Batch fakeResponse = new Mock_IAAI_VPEListing_Batch(200, 'Complete', responseText, null);
        	Test.setMock(HttpCalloutMock.class, fakeResponse);
            IAAI_VPEListingBatchScheduler sh1 = new IAAI_VPEListingBatchScheduler();
            Datetime cronTime = System.now().addMinutes(30);
            String day = string.valueOf(cronTime.day());
            String month = string.valueOf(cronTime.month());
            String hour = string.valueOf(cronTime.hour());
            String second = string.valueOf(cronTime.second());
            String year = string.valueOf(cronTime.year());
            String minute = string.valueOf(cronTime.minute());
        	String strSchedule = '0 ' + minute + ' ' + hour + ' ? ' + month + ' 2-6' + ' ' + year;
        	String jobId = system.schedule('Test Class for Scheduler', strSchedule, sh1);
        	partnerDetail.Cron_Id__c = jobId;
        	update partnerDetail;
        Test.stopTest(); 
    }
    @isTest
    private static void handleBoltOnBulkListingFailure() {
        List<VPE_Listings__c> listing = new List<VPE_Listings__c>();
        VPE_Listings__c vpl = new VPE_Listings__c();
        vpl.VIN__c = '1gth5cea0g1152730';
        vpl.Make__c = 'Gmc';
        vpl.Model__c = 'Canyon Extended Cab Sle';
        vpl.Model_Year__c = '2016';
        vpl.Listing_Id__c = '5e0e60ab384bf92e0d46dd33';
        vpl.Mileage__c = 95250;
        vpl.Blackbookupdated__c = true;
        
        VPE_Listings__c vpl1 = new VPE_Listings__c();
        vpl1.VIN__c = '3kpfk4a70he136753';
        vpl1.Make__c = 'Gmc';
        vpl1.Model__c = 'Canyon Extended Cab Sle';
        vpl1.Model_Year__c = '2016';
        vpl1.Listing_Id__c = '5e0e6094384bf92e0d46dd31';
        vpl1.Mileage__c = 95250;
        vpl1.Blackbookupdated__c = true;
        
        listing.add(vpl);
        listing.add(vpl1);
        
        insert listing;
        // Database.executeBatch(new HandleBoltOnBulkListing(listing, 'test@test.com'));
    }
    @isTest
    private static void handleBoltOnBulkListingSuccess() {
        List<VPE_Listings__c> listing = new List<VPE_Listings__c>();
        VPE_Listings__c vpl = new VPE_Listings__c();
        vpl.VIN__c = '1gth5cea0g1152730';
        vpl.Make__c = 'Gmc';
        vpl.Model__c = 'Canyon Extended Cab Sle';
        vpl.Model_Year__c = '2016';
        vpl.Listing_Id__c = '5e0e60ab384bf92e0d46dd33';
        vpl.Mileage__c = 95250;
        vpl.Blackbookupdated__c = true;
        
        VPE_Listings__c vpl1 = new VPE_Listings__c();
        vpl1.VIN__c = '3kpfk4a70he136753';
        vpl1.Make__c = 'Gmc';
        vpl1.Model__c = 'Canyon Extended Cab Sle';
        vpl1.Model_Year__c = '2016';
        vpl1.Listing_Id__c = '5e0e6094384bf92e0d46dd31';
        vpl1.Mileage__c = 95250;
        vpl1.Blackbookupdated__c = true;
        
        listing.add(vpl);
        listing.add(vpl1);
        
        Test.startTest();
        // Database.executeBatch(new HandleBoltOnBulkListing(listing, 'test@test.com'));
        Test.stopTest();
    }
    @IsTest
    static void GetListingCronHandlerTet() {
        VPE_Listing_Partner__c partner = [SELECT Id, Name, Call_Frequency_Min__c FROM VPE_Listing_Partner__c where Name = 'CARVIO' limit 1];
        partner.Call_Frequency_Min__c = 30;
        update partner;
    }
}