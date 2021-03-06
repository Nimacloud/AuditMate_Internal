//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

public class SchindlerJson1 {

	public Boolean Successful;
	public List<OcrPages> OcrPages;

	public class OcrPages {
		public Integer PageNumber;
		public Boolean Successful;
		public List<Lines> Lines;
	}

	public class Words {
		public String WordText;
		public Integer LineNumber;
		public Integer WordNumber;
		public Integer XLeft;
		public Integer YTop;
		public Integer Width;
		public Integer Height;
		public Double ConfidenceLevel;
		public Integer BlockNumber;
		public Integer ParagraphNumber;
		public Integer PageNumber;
	}

	public class Lines {
		public String LineText;
		public List<Words> Words;
	}
	
	public static SchindlerJson1 parse(String json) {
		return (SchindlerJson1) System.JSON.deserialize(json, SchindlerJson1.class);
	}
}