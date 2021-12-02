@IsTest
public class IAAI_PredictivePriceJsonResponse_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"epvResponse\": {'+
		'        \"fullStockNumber\": \"NONE\",'+
		'        \"stockID\": 0,'+
		'        \"vin\": \"3P3BK46KXKT968258\",'+
		'        \"year\": 1989,'+
		'        \"make\": \"PLYMOUTH\",'+
		'        \"model\": \"RELIANT\",'+
		'        \"series\": \"LE\",'+
		'        \"engineDescription\": \"2.5L I4 FI  F\",'+
		'        \"vehicleClass\": \"Non Luxury Traditional Compact\",'+
		'        \"fuelType\": \"Gas\",'+
		'        \"driveLine\": \"FWD\",'+
		'        \"cylinders\": \"4\",'+
		'        \"transmissionType\": \"Manual\",'+
		'        \"predictedPrice\": 1150.0,'+
		'        \"errorRange\": 0.252551,'+
		'        \"max95\": 1730.8673,'+
		'        \"min95\": 569.1326999999999,'+
		'        \"max75\": 1483.9986975,'+
		'        \"min75\": 816.0013025000001,'+
		'        \"max68\": 1440.43365,'+
		'        \"min68\": 859.56635,'+
		'        \"filterCode\": 0,'+
		'        \"filterCodeDescription\": \"\"'+
		'    },'+
		'    \"referenceId\": \"4bc10ee5482b3742b71c25a4c5ebfff9\",'+
		'    \"status\": \"ACCEPT\",'+
		'    \"rejectReasonCode\": null,'+
		'    \"rejectReasonDescription\": null'+
		'}';
		IAAI_PredictivePriceJsonResponse obj = IAAI_PredictivePriceJsonResponse.parse(json);
		System.assert(obj != null);
	}
}