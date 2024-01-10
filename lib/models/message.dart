class Message {
  Message({
    required this.msg,
    required this.read,
    required this.told,
    required this.fromld,
    required this.type,
    required this.sent,
  });
  late final String msg;
  late final String read;
  late final String told;
  late final String fromld;
  late final String sent;
  late final Type type;

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    read = json['read'].toString();
    told = json['told'].toString();
    fromld = json['fromld'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['read'] = read;
    data['told'] = told;
    data['fromld'] = fromld;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
