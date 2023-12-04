class BaseMessageJsonMapper{

  static Map<String, dynamic> getPreProcessedMsgJson(json){

    Map<String, dynamic> map = {};
    var isCMDProcessed = json["cmd"];

    if(isCMDProcessed != null){
      map = parseTextJsonWithCMD(json);
    }else{
      map = parseTextJsonWithoutCMD(json);
    }

    return map;

  }

  static Map<String, dynamic> parseTextJsonWithoutCMD(json){
    Map<String, dynamic> map = {};

    if(json["message"] != null && json["message"] != "") {
      map.putIfAbsent("type", () => "MESG");
    }else{
      map.putIfAbsent("type", () => "FILE");
    }
    map.putIfAbsent("message_id", () => json["message_id"]);
    map.putIfAbsent("message", () => json["message"]);
    map.putIfAbsent("data", () => json["data"]);
    map.putIfAbsent("custom_type", () => json["custom_type"]);
    map.putIfAbsent("file", () => json["file"]);
    map.putIfAbsent("created_at", () => json["created_at"]);
    map.putIfAbsent("user", () => json["user"]);
    map.putIfAbsent("channel_url", () => json["channel_url"]);
    map.putIfAbsent("updated_at", () => json["updated_at"]);
    map.putIfAbsent("message_survival_seconds", () => json["message_survival_seconds"]);
    map.putIfAbsent("mentioned_users", () => json["mentioned_users"]);
    map.putIfAbsent("mention_type", () => json["mention_type"]);
    map.putIfAbsent("silent", () => json["silent"]);
    map.putIfAbsent("channel_type", () => json["channel_type"]);
    map.putIfAbsent("translations", () => json["translations"]);
    map.putIfAbsent("is_removed", () => json["is_removed"]);
    map.putIfAbsent("req_id", () => json["request_id"]);
    map.putIfAbsent("is_op_msg", () => json["is_op_msg"]);
    map.putIfAbsent("message_events", () => json["message_events"]);


    return map;

  }

  static Map<String, dynamic> parseTextJsonWithCMD(json) {
    Map<String, dynamic> map = {};
    map.putIfAbsent("type", () => json["cmd"]);
    map.putIfAbsent("message_id", () => json["msg_id"]);
    map.putIfAbsent("message", () => json["message"]);
    map.putIfAbsent("data", () => json["data"]);
    map.putIfAbsent("custom_type", () => json["custom_type"]);
    if(json["file"] == null){
      map.putIfAbsent("file", () => {});
    }
    map.putIfAbsent("created_at", () => json["ts"]);
    map.putIfAbsent("user", () => json["user"]);
    map.putIfAbsent("channel_url", () => json["channel_url"]);
    map.putIfAbsent("updated_at", () => json["last_updated_at"]);
    map.putIfAbsent("message_survival_seconds", () => json["message_retention_hour"]);
    map.putIfAbsent("mentioned_users", () => json["mentioned_users"]);
    map.putIfAbsent("mention_type", () => json["mention_type"]);
    map.putIfAbsent("silent", () => json["silent"]);
    map.putIfAbsent("message_retention_hour", () => json["message_retention_hour"]);
    map.putIfAbsent("channel_type", () => json["channel_type"]);
    map.putIfAbsent("translations", () => json["translations"]);
    map.putIfAbsent("is_removed", () => json["is_removed"]);
    map.putIfAbsent("req_id", () => json["req_id"]);
    map.putIfAbsent("is_op_msg", () => json["is_op_msg"]);
    map.putIfAbsent("message_events", () => json["message_events"]);
    return map;
  }
}