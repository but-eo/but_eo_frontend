enum TeamType { solo, team }

enum TeamCase { teenager, university, office, club, female, etc }

enum Event {
  soccer,
  futsal,
  baseball,
  basketball,
  badminton,
  tennis,
  tableTennis,
  bowling,
}

enum Region { seoul, gyeonggi, gangwon, chungcheong, jeolla, gyeongsang, jeju }

Region parseRegion(String? regionStr) {
  if (regionStr == null) return Region.seoul; // 기본값 지정 가능
  // 서버가 대문자면 소문자 변환 후 매칭
  final lowerStr = regionStr.toLowerCase();
  return Region.values.firstWhere(
    (e) => e.name == lowerStr,
    orElse: () => Region.seoul, // 기본값
  );
}

enum AgeGroup { teen, twenties, thirties, fortiesUp }

const teamTypeEnumMap = {TeamType.solo: "1인 팀", TeamType.team: "팀"};

const teamCaseEnumMap = {
  TeamCase.teenager: "청소년",
  TeamCase.university: "대학생",
  TeamCase.office: "직장인",
  TeamCase.club: "동호회",
  TeamCase.female: "여성",
  TeamCase.etc: "기타",
};

const eventEnumMap = {
  Event.soccer: "축구",
  Event.futsal: "풋살",
  Event.baseball: "야구",
  Event.basketball: "농구",
  Event.badminton: "배드민턴",
  Event.tennis: "테니스",
  Event.tableTennis: "탁구",
  Event.bowling: "볼링",
};

const regionEnumMap = {
  Region.seoul: "서울",
  Region.gyeonggi: "경기",
  Region.gangwon: "강원",
  Region.chungcheong: "충청",
  Region.jeolla: "전라",
  Region.gyeongsang: "경상",
  Region.jeju: "제주",
};

const ageGroupEnumMap = {
  AgeGroup.teen: "10대",
  AgeGroup.twenties: "20대",
  AgeGroup.thirties: "30대",
  AgeGroup.fortiesUp: "40대 이상",
};
