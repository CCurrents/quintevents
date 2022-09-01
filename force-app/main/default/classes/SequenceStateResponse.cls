public class SequenceStateResponse{
	public cls_data[] data;
	public cls_meta meta;
    
	class cls_data {
        public string type;
        public string id;
        public cls_links links;
	}
	public class cls_attributes {
		public cls_activeAt activeAt;
		public Integer bounceCount;	//0
		public cls_callCompletedAt callCompletedAt;
		public Integer clickCount;	//0
		public String createdAt;	//2022-08-01T12:35:30.000Z
		public Integer deliverCount;	//0
		public cls_errorReason errorReason;
		public Integer failureCount;	//0
		public Integer negativeReplyCount;	//0
		public Integer neutralReplyCount;	//0
		public Integer openCount;	//0
		public Integer optOutCount;	//0
		public cls_pauseReason pauseReason;
		public Integer positiveReplyCount;	//0
		public cls_repliedAt repliedAt;
		public Integer replyCount;	//0
		public Integer scheduleCount;	//0
		public String state;	//pending
		public String stateChangedAt;	//2022-08-01T12:35:30.000Z
		public String updatedAt;	//2022-08-01T12:35:30.000Z
	}
	class cls_activeAt {
	}
	class cls_callCompletedAt {
	}
	class cls_errorReason {
	}
	class cls_pauseReason {
	}
	class cls_repliedAt {
	}
	class cls_relationships {
		public cls_account account;
		public cls_activeStepMailings activeStepMailings;
		public cls_activeStepTasks activeStepTasks;
		public cls_batchItemCreator batchItemCreator;
		public cls_calls calls;
		public cls_creator creator;
		public cls_mailbox mailbox;
		public cls_mailings mailings;
		public cls_opportunity opportunity;
		public cls_prospect prospect;
		public cls_sequence sequence;
		public cls_sequenceStateRecipients sequenceStateRecipients;
		public cls_sequenceStep sequenceStep;
		public cls_tasks tasks;
	}
	class cls_account {
		public cls_data data;
	}
	class cls_activeStepMailings {
		public cls_data[] data;
		public cls_links links;
		public cls_meta meta;
	}
	class cls_links {
		public String self;	//https://api.outreach.io/api/v2/sequenceStates/908854
	}
	class cls_meta {
		public Integer count;	//1
		public boolean count_truncated;
	}
	class cls_activeStepTasks {
		public cls_data[] data;
		public cls_links links;
		public cls_meta meta;
	}
	class cls_batchItemCreator {
		public cls_data data;
	}
	class cls_calls {
		public cls_links links;
	}
	class cls_creator {
		public cls_data data;
	}
	class cls_mailbox {
		public cls_data data;
	}
	class cls_mailings {
		public cls_links links;
	}
	class cls_opportunity {
		public cls_data data;
	}
	class cls_prospect {
		public cls_data data;
	}
	class cls_sequence {
		public cls_data data;
	}
	class cls_sequenceStateRecipients {
		public cls_data[] data;
		public cls_links links;
		public cls_meta meta;
	}
	class cls_sequenceStep {
		public cls_data data;
	}
	class cls_tasks {
		public cls_links links;
	}

	public static SequenceStateResponse parse(String json){
		return (SequenceStateResponse) System.JSON.deserialize(json, SequenceStateResponse.class);
	}
}