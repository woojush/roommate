// lib/service/tabs/matching/check_list/checklist_item.dart

/// ---------------------------------------------------------------------------
/// 이 파일은 체크리스트 질문(8페이지)을 정의합니다.
/// 각 페이지는 List<ChecklistQuestion> 형태이며,
/// checklistPages는 2차원 리스트(List<List<ChecklistQuestion>>).
///
/// 8페이지 구성 예:
///   0: 생년, 성별, 학번, MBTI
///   1: 기숙사 기간, 생활관, 인실
///   2: 기상시간, 취침시간, 알람, 잠버릇(복수)
///   3: 샤워시간(복수), 샤워소요시간, 청소, 벌레
///   4: 흡연 여부, 음주 빈도, 주량, 술주사(직접 입력)
///   5: 친구초대, 운동, 공부(복수), 취미(직접 입력)
///   6: 야식, 실내 취식, 본가 가는 주기
///   7: 기타 메세지 (userMessage, 자유 기재)
/// ---------------------------------------------------------------------------

/// ChecklistQuestion 모델
class ChecklistQuestion {
  final String id;
  final String question;
  final String type;       // "picker", "button", "time", "input", "mbti" 등
  final dynamic options;   // picker/button: List<String>, mbti: List<List<String>>
  final bool multiSelect;  // 복수 선택 여부

  ChecklistQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.multiSelect = false,
  });
}

/// 학번 옵션 생성
List<String> generateStudentYearOptions() {
  List<String> years = [];
  // 96~99
  for (int i = 96; i <= 99; i++) {
    years.add(i.toString());
  }
  // 00 ~ 현재년도 앞2자리
  int currentYear = DateTime.now().year;
  int currentTwoDigits = int.parse(currentYear.toString().substring(2));
  for (int i = 0; i <= currentTwoDigits; i++) {
    years.add(i.toString().padLeft(2, '0'));
  }
  return years;
}

/// checklistPages: 8페이지
final List<List<ChecklistQuestion>> checklistPages = [
  // 페이지 0: 생년, 성별, 학번, MBTI(통합)
  [
    ChecklistQuestion(
      id: "birthYear",
      question: "생년",
      type: "picker",
      options: List.generate(
        50,
            (index) => (DateTime.now().year - 49 + index).toString(),
      ),
    ),
    ChecklistQuestion(
      id: "gender",
      question: "성별",
      type: "button",
      options: <String>["남", "여"],
    ),
    ChecklistQuestion(
      id: "studentYear",
      question: "학번",
      type: "picker",
      options: generateStudentYearOptions(),
    ),
    ChecklistQuestion(
      id: "mbti",
      question: "MBTI",
      type: "mbti",
      options: <List<String>>[
        <String>["I", "E"],
        <String>["S", "N"],
        <String>["F", "T"],
        <String>["P", "J"],
      ],
    ),
  ],
  // 페이지 1: 기숙사 기간, 생활관, 인실
  [
    ChecklistQuestion(
      id: "dormDuration",
      question: "기숙사 기간",
      type: "button",
      options: <String>["4개월", "6개월"],
    ),
    ChecklistQuestion(
      id: "dorm",
      question: "생활관",
      type: "button",
      options: <String>["제1생활관", "제2생활관", "제3생활관"],
    ),
    ChecklistQuestion(
      id: "roomType",
      question: "인실",
      type: "button",
      options: <String>[], // 선택된 생활관에 따라 동적 설정
    ),
  ],
  // 페이지 2: 기상시간, 취침시간, 알람, 잠버릇(복수)
  [
    ChecklistQuestion(
      id: "wakeUpTime",
      question: "기상시간",
      type: "time",
    ),
    ChecklistQuestion(
      id: "sleepTime",
      question: "취침시간",
      type: "time",
    ),
    ChecklistQuestion(
      id: "alarm",
      question: "알람",
      type: "button",
      options: <String>["잠만보", "중간", "잘들어요"],
    ),
    ChecklistQuestion(
      id: "sleepHabit",
      question: "잠버릇",
      type: "button",
      options: <String>["없음", "이갈이", "잠꼬대", "코골이"],
      multiSelect: true,
    ),
  ],
  // 페이지 3: 샤워시간(복수), 샤워소요시간, 청소, 벌레
  [
    ChecklistQuestion(
      id: "showerTime",
      question: "샤워시간",
      type: "button",
      options: <String>["아침", "저녁", "유동적"],
      multiSelect: true,
    ),
    ChecklistQuestion(
      id: "showerDuration",
      question: "샤워소요시간",
      type: "picker",
      // ex) 5분,10분,...40분 이상
      options: <String>["5분", "10분", "15분", "20분", "25분", "30분", "35분", "40분 이상"],
    ),
    ChecklistQuestion(
      id: "cleaning",
      question: "청소",
      type: "button",
      options: <String>["그때그때", "중간", "한번에"],
    ),
    ChecklistQuestion(
      id: "pest",
      question: "벌레",
      type: "button",
      options: <String>["극혐", "못잡음", "중간", "잡음", "귀여움"],
    ),
  ],
  // 페이지 4: 흡연 여부, 음주 빈도, 주량, 술주사(직접입력)
  [
    ChecklistQuestion(
      id: "smoking",
      question: "흡연 여부",
      type: "button",
      options: <String>["흡연", "비흡연"],
    ),
    ChecklistQuestion(
      id: "drinkingFrequency",
      question: "음주 빈도",
      type: "button",
      options: <String>["안마심", "보통", "자주", "매일"],
    ),
    ChecklistQuestion(
      id: "alcoholAmount",
      question: "주량",
      type: "picker",
      options: <String>["0병", "반병", "한병", "한병반", "두병", "두병반", "세병", "세병반", "네병 이상"],
    ),
    ChecklistQuestion(
      id: "drinkingExperience",
      question: "술주사",
      type: "input",
    ),
  ],
  // 페이지 5: 친구초대, 운동, 공부(복수), 취미(직접입력)
  [
    ChecklistQuestion(
      id: "inviteFriends",
      question: "친구초대",
      type: "button",
      options: <String>["상관 X", "싫어요", "사전허락"],
    ),
    ChecklistQuestion(
      id: "exercise",
      question: "운동",
      type: "button",
      options: <String>["안함", "가끔", "매일"],
    ),
    ChecklistQuestion(
      id: "studyPlace",
      question: "공부",
      type: "button",
      options: <String>["기숙사", "도서관", "유동적"],
      multiSelect: true,
    ),
    ChecklistQuestion(
      id: "hobby",
      question: "취미",
      type: "input",
    ),
  ],
  // 페이지 6: 야식, 실내 취식, 본가 가는 주기
  [
    ChecklistQuestion(
      id: "lateSnack",
      question: "야식",
      type: "button",
      options: <String>["안먹음", "별로", "중간", "좋아", "자주"],
    ),
    ChecklistQuestion(
      id: "indoorEating",
      question: "실내 취식",
      type: "button",
      options: <String>["싫어요", "냄새 안나면", "과자정도", "상관X"],
    ),
    ChecklistQuestion(
      id: "homeVisitFrequency",
      question: "본가 가는 주기",
      type: "button",
      options: <String>["방학", "매달", "격주", "매주"],
    ),
  ],
  // 페이지 7: 마지막 페이지 -> 추가 메세지
  [
    ChecklistQuestion(
      id: "userMessage",
      question: "추가 메세지 (하고 싶은 말)",
      type: "input",
      // options: null
    ),
  ],
];
