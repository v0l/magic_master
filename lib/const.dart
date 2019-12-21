const KaraokeInfo = "MAGIC_KARAOKE";

const MagicUUID = "MAGIC_UUID";

const MobileTopicStart = "Entermedia/Karaoke/Mobile";

const KaraokeTopicStart = "Entermedia/Karaoke";

const String SongSearch = """
  select distinct(number), title, artist, song_type, nation, newsong, hitsong, bestsong, notes, :db as db
from songlist 
where title like :search
or artist like :search""";

const String SongSearchNoNotes = """
  select distinct(number), title, artist, song_type, nation, newsong, hitsong, bestsong, :db as db
from songlist 
where title like :search
or artist like :search""";

const DBNames = {
  "ARABSONG": "العالم العربي‎ al-ʿālam al-ʿarabī (Arab)",
  "AST19K": "Pilipinas (Philippines)",
  "BGDSONG": "বাংলাদেশ (Bangladesh)",
  "CHIHYMN": null,
  "CHISONG": "中国 (China)",
  "ESPSONG": "España (Spain)",
  "FINSONG": null,
  "GERSONG": "Deutschland (Germany)",
  "IDNSONG": "Indonesia",
  "INDSONG": "Bhārat (India)",
  "JPSONG": "日本 (Japan)",
  "KORBUL": "HYM2",
  "KORHYMN": "HYM1",
  "KORKID": "HYM3",
  "KORLSONG": null,
  "KORSONG": "한국 (Korea)",
  "MNGSONG": "Монгол Улс (Mongolia)",
  "POPSONG": "POP",
  "PUPPY": "HYM4",
  "RAFSONG": null,
  "RUSSONG": "Росси́я (Russia)",
  "THASONG": "ประเทศไทย (Thailand)",
  "TURSONG": "Türkiye Cumhuriyeti (Turkey)",
  "VIETSONG": "Việt Nam (Vietnam)"
};

const HymDB = ["PUPPY", "KORKID", "KORHYMN", "KORBUL"];

const DBFilter = "MAGIC_DB_SELECT";

const DefaultDBFilter = ["POPSONG"];

const WithAlbumCovers = false;