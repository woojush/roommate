import 'dart:convert'; // JSON 파싱을 위한 패키지
import 'package:findmate1/service/tabs/dorm_info/info_model.dart'; // 데이터 모델

// 백엔드 서비스에서 데이터를 처리하는 클래스
class InfoService {
  // 예시로 로컬 데이터로 카테고리 데이터를 제공 (API 호출로 대체 가능)
  List<InfoCategory> fetchCategories() {
    return [
      InfoCategory(
        title: '공지사항 및 자료실',
        items: [
          InfoItem(
            title: '공지사항',
            link: 'https://www.gachon.ac.kr/dormitory/2351/subview.do',
          ),
          InfoItem(
            title: '자료실',
            link: 'https://www.gachon.ac.kr/dormitory/2352/subview.do',
          ),
        ],
      ),
      InfoCategory(
        title: '시설 및 전화번호 안내',
        items: [
          InfoItem(
            title: '제1학생생활관',
            children: [
              InfoItem(
                title: '수용현황',
                link: 'https://www.gachon.ac.kr/dormitory/2366/subview.do',
              ),
              InfoItem(
                title: '호실/시설안내',
                link: 'https://www.gachon.ac.kr/dormitory/2367/subview.do',
              ),
              InfoItem(
                title: '전화번호 안내',
                link: 'https://www.gachon.ac.kr/dormitory/2368/subview.do',
              ),
            ],
          ),
          InfoItem(
            title: '제2학생생활관',
            children: [
              InfoItem(
                title: '수용현황',
                link: 'https://www.gachon.ac.kr/dormitory/2369/subview.do',
              ),
              InfoItem(
                title: '호실/시설안내',
                link: 'https://www.gachon.ac.kr/dormitory/2370/subview.do',
              ),
              InfoItem(
                title: '전화번호 안내',
                link: 'https://www.gachon.ac.kr/dormitory/2371/subview.do',
              ),
            ],
          ),
          InfoItem(
            title: '제3학생생활관',
            children: [
              InfoItem(
                title: '수용현황',
                link: 'https://www.gachon.ac.kr/dormitory/9347/subview.do',
              ),
              InfoItem(
                title: '호실/시설안내',
                link: 'https://www.gachon.ac.kr/dormitory/9348/subview.do',
              ),
              InfoItem(
                title: '전화번호 안내',
                link: 'https://www.gachon.ac.kr/dormitory/9349/subview.do',
              ),
            ],
          ),
        ],
      ),
      InfoCategory(
        title: '생활관 안내 및 수칙, 편의시설',
        items: [
          InfoItem(title: '생활관 이용안내', link: 'https://www.gachon.ac.kr/dormitory/2346/subview.do'),
          InfoItem(
            title: '생활관 수칙',
            children: [
              InfoItem(
                title: '상점기준표',
                link: 'https://www.gachon.ac.kr/dormitory/7747/subview.do',
              ),
              InfoItem(
                title: '벌점기준표',
                link: 'https://www.gachon.ac.kr/dormitory/7748/subview.do',
              ),
            ],
          ),
        ],
      ),
      InfoCategory(
        title: '입.퇴사 안내',
        items: [
          InfoItem(
            title: '입사 안내',
            children: [
              InfoItem(
                title: '입사일정안내',
                link: 'https://www.gachon.ac.kr/dormitory/2372/subview.do',
              ),
              InfoItem(
                title: '선발안내 및 절차',
                link: 'https://www.gachon.ac.kr/dormitory/2373/subview.do',
              ),
              InfoItem(
                title: '생활관비 안내',
                link: 'https://www.gachon.ac.kr/dormitory/2374/subview.do',
              ),
            ],
          ),
          InfoItem(
            title: '퇴사 안내',
            children: [
              InfoItem(
                title: '퇴사안내',
                link: 'https://www.gachon.ac.kr/dormitory/2375/subview.do',
              ),
              InfoItem(
                title: '퇴사절차/호실이동',
                link: 'https://www.gachon.ac.kr/dormitory/2376/subview.do',
              ),
              InfoItem(
                title: '환불 기준표 안내',
                link: 'https://www.gachon.ac.kr/dormitory/2376/subview.do',
              ),
            ],
          ),
        ],
      ),
      InfoCategory(
        title: '생활관 소개',
        items: [
          InfoItem(
            title: '인삿말',
            link: 'https://www.gachon.ac.kr/dormitory/2337/subview.do',
          ),
          InfoItem(
            title: '설립목적',
            link: 'https://www.gachon.ac.kr/dormitory/2338/subview.do',
          ),
          InfoItem(
            title: '조직도',
            link: 'https://www.gachon.ac.kr/dormitory/2339/subview.do',
          ),
          InfoItem(
            title: '오시는길',
            link: 'https://www.gachon.ac.kr/dormitory/2340/subview.do',
          ),
        ],
      ),
    ];
  }
}
