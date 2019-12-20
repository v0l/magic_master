class RecordingSearch {
  String created;
  int count;
  int offset;
  List<Recordings> recordings;

  RecordingSearch({this.created, this.count, this.offset, this.recordings});

  RecordingSearch.fromJson(Map<String, dynamic> json) {
    created = json['created'];
    count = json['count'];
    offset = json['offset'];
    if (json['recordings'] != null) {
      recordings = new List<Recordings>();
      json['recordings'].forEach((v) {
        recordings.add(new Recordings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created'] = this.created;
    data['count'] = this.count;
    data['offset'] = this.offset;
    if (this.recordings != null) {
      data['recordings'] = this.recordings.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Recordings {
  String id;
  int score;
  String title;
  int length;
  bool video;
  List<ArtistCredit> artistCredit;
  List<Releases> releases;
  List<Tags> tags;
  List<String> isrcs;
  String disambiguation;

  Recordings(
      {this.id,
      this.score,
      this.title,
      this.length,
      this.video,
      this.artistCredit,
      this.releases,
      this.tags,
      this.isrcs,
      this.disambiguation});

  Recordings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    score = json['score'];
    title = json['title'];
    length = json['length'];
    video = json['video'];
    if (json['artist-credit'] != null) {
      artistCredit = new List<ArtistCredit>();
      json['artist-credit'].forEach((v) {
        artistCredit.add(new ArtistCredit.fromJson(v));
      });
    }
    if (json['releases'] != null) {
      releases = new List<Releases>();
      json['releases'].forEach((v) {
        releases.add(new Releases.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      tags = new List<Tags>();
      json['tags'].forEach((v) {
        tags.add(new Tags.fromJson(v));
      });
    }
    isrcs = json['isrcs']?.cast<String>();
    disambiguation = json['disambiguation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['score'] = this.score;
    data['title'] = this.title;
    data['length'] = this.length;
    data['video'] = this.video;
    if (this.artistCredit != null) {
      data['artist-credit'] = this.artistCredit.map((v) => v.toJson()).toList();
    }
    if (this.releases != null) {
      data['releases'] = this.releases.map((v) => v.toJson()).toList();
    }
    if (this.tags != null) {
      data['tags'] = this.tags.map((v) => v.toJson()).toList();
    }
    data['isrcs'] = this.isrcs;
    data['disambiguation'] = this.disambiguation;
    return data;
  }
}

class ArtistCredit {
  String joinphrase;
  String name;
  Artist artist;

  ArtistCredit({this.joinphrase, this.name, this.artist});

  ArtistCredit.fromJson(Map<String, dynamic> json) {
    joinphrase = json['joinphrase'];
    name = json['name'];
    artist =
        json['artist'] != null ? new Artist.fromJson(json['artist']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['joinphrase'] = this.joinphrase;
    data['name'] = this.name;
    if (this.artist != null) {
      data['artist'] = this.artist.toJson();
    }
    return data;
  }
}

class Artist {
  String id;
  String name;
  String sortName;
  List<Aliases> aliases;

  Artist({this.id, this.name, this.sortName, this.aliases});

  Artist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sortName = json['sort-name'];
    if (json['aliases'] != null) {
      aliases = new List<Aliases>();
      json['aliases'].forEach((v) {
        aliases.add(new Aliases.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['sort-name'] = this.sortName;
    if (this.aliases != null) {
      data['aliases'] = this.aliases.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Aliases {
  String sortName;
  String name;
  String locale;
  String type;
  dynamic primary;
  dynamic beginDate;
  dynamic endDate;
  String typeId;

  Aliases(
      {this.sortName,
      this.name,
      this.locale,
      this.type,
      this.primary,
      this.beginDate,
      this.endDate,
      this.typeId});

  Aliases.fromJson(Map<String, dynamic> json) {
    sortName = json['sort-name'];
    name = json['name'];
    locale = json['locale'];
    type = json['type'];
    primary = json['primary'];
    beginDate = json['begin-date'];
    endDate = json['end-date'];
    typeId = json['type-id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sort-name'] = this.sortName;
    data['name'] = this.name;
    data['locale'] = this.locale;
    data['type'] = this.type;
    data['primary'] = this.primary;
    data['begin-date'] = this.beginDate;
    data['end-date'] = this.endDate;
    data['type-id'] = this.typeId;
    return data;
  }
}

class Releases {
  String id;
  int count;
  String title;
  String status;
  List<ArtistCredit> artistCredit;
  ReleaseGroup releaseGroup;
  String date;
  String country;
  List<ReleaseEvents> releaseEvents;
  int trackCount;
  List<Media> media;
  String disambiguation;

  Releases(
      {this.id,
      this.count,
      this.title,
      this.status,
      this.artistCredit,
      this.releaseGroup,
      this.date,
      this.country,
      this.releaseEvents,
      this.trackCount,
      this.media,
      this.disambiguation});

  Releases.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    count = json['count'];
    title = json['title'];
    status = json['status'];
    if (json['artist-credit'] != null) {
      artistCredit = new List<ArtistCredit>();
      json['artist-credit'].forEach((v) {
        artistCredit.add(new ArtistCredit.fromJson(v));
      });
    }
    releaseGroup = json['release-group'] != null
        ? new ReleaseGroup.fromJson(json['release-group'])
        : null;
    date = json['date'];
    country = json['country'];
    if (json['release-events'] != null) {
      releaseEvents = new List<ReleaseEvents>();
      json['release-events'].forEach((v) {
        releaseEvents.add(new ReleaseEvents.fromJson(v));
      });
    }
    trackCount = json['track-count'];
    if (json['media'] != null) {
      media = new List<Media>();
      json['media'].forEach((v) {
        media.add(new Media.fromJson(v));
      });
    }
    disambiguation = json['disambiguation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['count'] = this.count;
    data['title'] = this.title;
    data['status'] = this.status;
    if (this.artistCredit != null) {
      data['artist-credit'] = this.artistCredit.map((v) => v.toJson()).toList();
    }
    if (this.releaseGroup != null) {
      data['release-group'] = this.releaseGroup.toJson();
    }
    data['date'] = this.date;
    data['country'] = this.country;
    if (this.releaseEvents != null) {
      data['release-events'] =
          this.releaseEvents.map((v) => v.toJson()).toList();
    }
    data['track-count'] = this.trackCount;
    if (this.media != null) {
      data['media'] = this.media.map((v) => v.toJson()).toList();
    }
    data['disambiguation'] = this.disambiguation;
    return data;
  }
}

class ReleaseGroup {
  String id;
  String title;
  String typeId;
  String primaryType;
  List<String> secondaryTypes;
  String disambiguation;

  ReleaseGroup(
      {this.id,
      this.title,
      this.typeId,
      this.primaryType,
      this.secondaryTypes,
      this.disambiguation});

  ReleaseGroup.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    typeId = json['type-id'];
    primaryType = json['primary-type'];
    secondaryTypes = json['secondary-types']?.cast<String>();
    disambiguation = json['disambiguation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['type-id'] = this.typeId;
    data['primary-type'] = this.primaryType;
    data['secondary-types'] = this.secondaryTypes;
    data['disambiguation'] = this.disambiguation;
    return data;
  }
}

class ReleaseEvents {
  String date;
  Area area;

  ReleaseEvents({this.date, this.area});

  ReleaseEvents.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    area = json['area'] != null ? new Area.fromJson(json['area']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    if (this.area != null) {
      data['area'] = this.area.toJson();
    }
    return data;
  }
}

class Area {
  String id;
  String name;
  String sortName;
  List<String> iso31661Codes;

  Area({this.id, this.name, this.sortName, this.iso31661Codes});

  Area.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sortName = json['sort-name'];
    iso31661Codes = json['iso-3166-1-codes']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['sort-name'] = this.sortName;
    data['iso-3166-1-codes'] = this.iso31661Codes;
    return data;
  }
}

class Media {
  int position;
  String format;
  List<Track> track;
  int trackCount;
  int trackOffset;

  Media(
      {this.position,
      this.format,
      this.track,
      this.trackCount,
      this.trackOffset});

  Media.fromJson(Map<String, dynamic> json) {
    position = json['position'];
    format = json['format'];
    if (json['track'] != null) {
      track = new List<Track>();
      json['track'].forEach((v) {
        track.add(new Track.fromJson(v));
      });
    }
    trackCount = json['track-count'];
    trackOffset = json['track-offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['position'] = this.position;
    data['format'] = this.format;
    if (this.track != null) {
      data['track'] = this.track.map((v) => v.toJson()).toList();
    }
    data['track-count'] = this.trackCount;
    data['track-offset'] = this.trackOffset;
    return data;
  }
}

class Track {
  String id;
  String number;
  String title;
  int length;

  Track({this.id, this.number, this.title, this.length});

  Track.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    title = json['title'];
    length = json['length'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['number'] = this.number;
    data['title'] = this.title;
    data['length'] = this.length;
    return data;
  }
}

class Tags {
  int count;
  String name;

  Tags({this.count, this.name});

  Tags.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['name'] = this.name;
    return data;
  }
}
