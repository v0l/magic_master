import 'dart:convert';

class KaraokeConfig {
  final String model;
  final String version;
  final String broker;
  final String topic;

  KaraokeConfig({
    this.model,
    this.version,
    this.broker,
    this.topic,
  });

  static KaraokeConfig fromJson(String data) {
    try {
      final jdata = json.decode(data);

      final model = jdata["MODEL"] as String;
      final version = jdata["VERSION"] as String;
      final broker = jdata["BROKER"] as String;
      final topic = jdata["TOPIC"] as String;

      if ((model?.isEmpty ?? true) ||
          (version?.isEmpty ?? true) ||
          (broker?.isEmpty ?? true) ||
          (topic?.isEmpty ?? true)) {}

      return KaraokeConfig(
        model: model,
        version: version,
        broker: broker,
        topic: topic,
      );
    } catch (Exception) {
      return null;
    }
  }

  String toJson() {
    return json.encode({
      "MODEL": model,
      "VERSION": version,
      "BROKER": broker,
      "TOPIC": topic,
    });
  }
}
