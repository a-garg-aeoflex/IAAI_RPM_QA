public class IAAI_PredictivePriceJsonResponse {

	public EpvResponse epvResponse;
	public String referenceId;
	public String status;
	public String rejectReasonCode;
	public List<rejectReasonDescription> rejectReasonDescription;

	public class EpvResponse {
		public String fullStockNumber;
		public Integer stockID;
		public String vin;
		public Integer year;
		public String make;
		public String model;
		public String series;
		public String engineDescription;
		public String vehicleClass;
		public String fuelType;
		public String driveLine;
		public String cylinders;
		public String transmissionType;
		public Double predictedPrice;
		public Double errorRange;
		public Double max95;
		public Double min95;
		public Double max75;
		public Double min75;
		public Double max68;
		public Double min68;
		public Integer filterCode;
		public String filterCodeDescription;
	}
    
    public class rejectReasonDescription {
		public List<String> messages;
	}
    
    
	public static IAAI_PredictivePriceJsonResponse parse(String json) {
        system.debug('------JSON--'+json);
		return (IAAI_PredictivePriceJsonResponse) System.JSON.deserialize(json, IAAI_PredictivePriceJsonResponse.class);
	}
   
}