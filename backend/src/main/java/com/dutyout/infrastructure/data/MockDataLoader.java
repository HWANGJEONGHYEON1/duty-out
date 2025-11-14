package com.dutyout.infrastructure.data;

import com.dutyout.domain.baby.entity.Baby;
import com.dutyout.domain.baby.entity.Gender;
import com.dutyout.domain.baby.repository.BabyRepository;
import com.dutyout.domain.community.entity.Comment;
import com.dutyout.domain.community.entity.CommunityPost;
import com.dutyout.domain.community.repository.CommentRepository;
import com.dutyout.domain.community.repository.CommunityPostRepository;
import com.dutyout.domain.feeding.entity.FeedingRecord;
import com.dutyout.domain.feeding.entity.FeedingType;
import com.dutyout.domain.feeding.repository.FeedingRecordRepository;
import com.dutyout.domain.user.entity.AuthProvider;
import com.dutyout.domain.user.entity.User;
import com.dutyout.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 목 데이터 로더
 *
 * Clean Architecture - Infrastructure Layer
 *
 * 로컬 개발 및 테스트를 위한 샘플 데이터를 자동으로 생성합니다.
 *
 * 생성 데이터:
 * - 테스트 사용자 2명
 * - 테스트 아기 2명 (각 사용자당 1명)
 * - 샘플 수유 기록
 * - 샘플 커뮤니티 게시글 및 댓글
 *
 * 주의사항:
 * - dev, local 프로필에서만 실행
 * - SleepGuidelineDataLoader 이후에 실행 (Order 설정)
 * - 이미 데이터가 있으면 스킵
 */
@Slf4j
@Component
@Profile({"dev", "local"})
@Order(2) // SleepGuidelineDataLoader(기본 Order=1) 다음에 실행
@RequiredArgsConstructor
public class MockDataLoader implements CommandLineRunner {

    private final UserRepository userRepository;
    private final BabyRepository babyRepository;
    private final FeedingRecordRepository feedingRecordRepository;
    private final CommunityPostRepository communityPostRepository;
    private final CommentRepository commentRepository;

    @Override
    public void run(String... args) {
        log.info("🎭 목 데이터 로딩 시작...");

        // 이미 데이터가 있으면 스킵
        if (userRepository.count() > 0) {
            log.info("이미 사용자 데이터가 존재합니다. 목 데이터 로딩을 스킵합니다.");
            return;
        }

        // 1. 테스트 사용자 생성
        List<User> users = createTestUsers();
        log.info("✅ 테스트 사용자 {}명 생성 완료", users.size());

        // 2. 테스트 아기 생성
        List<Baby> babies = createTestBabies(users);
        log.info("✅ 테스트 아기 {}명 생성 완료", babies.size());

        // 3. 샘플 수유 기록 생성
        int feedingCount = createFeedingRecords(babies);
        log.info("✅ 샘플 수유 기록 {}개 생성 완료", feedingCount);

        // 4. 샘플 커뮤니티 게시글 생성
        List<CommunityPost> posts = createCommunityPosts(users);
        log.info("✅ 샘플 커뮤니티 게시글 {}개 생성 완료", posts.size());

        // 5. 샘플 댓글 생성
        int commentCount = createComments(users, posts);
        log.info("✅ 샘플 댓글 {}개 생성 완료", commentCount);

        log.info("🎉 목 데이터 로딩 완료!");
        log.info("📧 테스트 계정: test1@test.com, test2@test.com");
    }

    /**
     * 테스트 사용자 생성
     */
    private List<User> createTestUsers() {
        List<User> users = new ArrayList<>();

        // 사용자 1: 김민준 (4개월 아기 부모)
        User user1 = User.builder()
                .email("test1@test.com")
                .name("김민준")
                .provider(AuthProvider.KAKAO)
                .providerId("kakao_test_1")
                .profileImage("https://via.placeholder.com/150/0000FF/808080?text=User1")
                .build();
        users.add(userRepository.save(user1));

        // 사용자 2: 이서연 (6개월 아기 부모)
        User user2 = User.builder()
                .email("test2@test.com")
                .name("이서연")
                .provider(AuthProvider.GOOGLE)
                .providerId("google_test_2")
                .profileImage("https://via.placeholder.com/150/FF0000/FFFFFF?text=User2")
                .build();
        users.add(userRepository.save(user2));

        return users;
    }

    /**
     * 테스트 아기 생성
     */
    private List<Baby> createTestBabies(List<User> users) {
        List<Baby> babies = new ArrayList<>();

        // 아기 1: 하준이 (4개월, 남아)
        Baby baby1 = Baby.builder()
                .userId(users.get(0).getId())
                .name("하준이")
                .birthDate(LocalDate.now().minusMonths(4))
                .gender(Gender.MALE)
                .gestationalWeeks(40) // 만삭
                .profileImage("https://via.placeholder.com/150/00FF00/000000?text=Baby1")
                .build();
        babies.add(babyRepository.save(baby1));

        // 아기 2: 서윤이 (6개월, 여아)
        Baby baby2 = Baby.builder()
                .userId(users.get(1).getId())
                .name("서윤이")
                .birthDate(LocalDate.now().minusMonths(6))
                .gender(Gender.FEMALE)
                .gestationalWeeks(38)
                .profileImage("https://via.placeholder.com/150/FFFF00/000000?text=Baby2")
                .build();
        babies.add(babyRepository.save(baby2));

        return babies;
    }

    /**
     * 샘플 수유 기록 생성
     */
    private int createFeedingRecords(List<Baby> babies) {
        int count = 0;
        LocalDateTime now = LocalDateTime.now();

        // 아기 1 (하준이) - 오늘의 수유 기록
        Baby baby1 = babies.get(0);

        // 오전 수유
        feedingRecordRepository.save(FeedingRecord.builder()
                .babyId(baby1.getId())
                .feedingTime(now.minusHours(8).withMinute(0))
                .type(FeedingType.BREAST)
                .amountMl(120)
                .note("왼쪽 10분, 오른쪽 10분")
                .build());
        count++;

        feedingRecordRepository.save(FeedingRecord.builder()
                .babyId(baby1.getId())
                .feedingTime(now.minusHours(5).withMinute(30))
                .type(FeedingType.BOTTLE)
                .amountMl(150)
                .note("잘 먹음")
                .build());
        count++;

        // 오후 수유
        feedingRecordRepository.save(FeedingRecord.builder()
                .babyId(baby1.getId())
                .feedingTime(now.minusHours(2).withMinute(0))
                .type(FeedingType.BREAST)
                .amountMl(130)
                .note("졸려하면서 먹음")
                .build());
        count++;

        // 아기 2 (서윤이) - 이유식 포함
        Baby baby2 = babies.get(1);

        feedingRecordRepository.save(FeedingRecord.builder()
                .babyId(baby2.getId())
                .feedingTime(now.minusHours(7).withMinute(0))
                .type(FeedingType.BOTTLE)
                .amountMl(180)
                .note("아침 분유")
                .build());
        count++;

        feedingRecordRepository.save(FeedingRecord.builder()
                .babyId(baby2.getId())
                .feedingTime(now.minusHours(4).withMinute(0))
                .type(FeedingType.SOLID)
                .amountMl(50)
                .note("이유식 - 호박죽 잘 먹음")
                .build());
        count++;

        feedingRecordRepository.save(FeedingRecord.builder()
                .babyId(baby2.getId())
                .feedingTime(now.minusHours(1).withMinute(30))
                .type(FeedingType.BOTTLE)
                .amountMl(200)
                .note("오후 분유")
                .build());
        count++;

        return count;
    }

    /**
     * 샘플 커뮤니티 게시글 생성
     */
    private List<CommunityPost> createCommunityPosts(List<User> users) {
        List<CommunityPost> posts = new ArrayList<>();

        // 게시글 1: 수면 교육 성공 사례
        CommunityPost post1 = CommunityPost.builder()
                .userId(users.get(0).getId())
                .title("4개월 아기 밤잠 통잠 드디어 성공했어요!")
                .content("안녕하세요! 드디어 통잠에 성공했습니다.\n\n" +
                        "수면교육 시작한지 2주만에 성과가 나타났어요.\n" +
                        "깨시를 정확히 지키고, 낮잠을 너무 늦게 재우지 않는게 핵심이었던 것 같아요.\n\n" +
                        "혹시 같은 고민하시는 분들께 도움이 되길 바랍니다!")
                .anonymousAuthor("익명123")
                .build();
        post1.increaseLikeCount();
        post1.increaseLikeCount();
        post1.increaseLikeCount();
        posts.add(communityPostRepository.save(post1));

        // 게시글 2: 낮잠 고민
        CommunityPost post2 = CommunityPost.builder()
                .userId(users.get(1).getId())
                .title("6개월 아기 낮잠 30분만 자고 깨요 ㅠㅠ")
                .content("6개월 된 아기인데 낮잠을 항상 30분만 자고 깨서 너무 힘들어요.\n\n" +
                        "어떻게 하면 낮잠을 길게 잘 수 있을까요?\n" +
                        "혹시 비슷한 경험 있으신 분 계신가요?")
                .anonymousAuthor("익명456")
                .build();
        posts.add(communityPostRepository.save(post2));

        // 게시글 3: 수유 고민
        CommunityPost post3 = CommunityPost.builder()
                .userId(users.get(0).getId())
                .title("모유 수유량 측정 어떻게 하시나요?")
                .content("모유 수유를 하고 있는데 아기가 얼마나 먹는지 잘 모르겠어요.\n" +
                        "체중이 잘 늘고 있긴 한데 불안해서요.\n" +
                        "다들 어떻게 확인하시나요?")
                .anonymousAuthor("익명789")
                .build();
        post3.increaseLikeCount();
        posts.add(communityPostRepository.save(post3));

        // 게시글 4: 이유식 시작
        CommunityPost post4 = CommunityPost.builder()
                .userId(users.get(1).getId())
                .title("이유식 시작했는데 잘 안먹어요")
                .content("6개월 되어서 이유식 시작했는데 한 숟가락도 안먹으려고 해요.\n" +
                        "언제쯤 잘 먹을까요? 걱정되네요.")
                .anonymousAuthor("익명234")
                .build();
        posts.add(communityPostRepository.save(post4));

        // 게시글 5: 수면 교육 팁
        CommunityPost post5 = CommunityPost.builder()
                .userId(users.get(0).getId())
                .title("수면 교육 시작하려는데 팁 좀 주세요!")
                .content("3개월 아기 수면 교육 시작하려고 하는데요,\n\n" +
                        "어떤 방법이 좋을까요? 울음 훈련? 아니면 다른 방법?\n" +
                        "경험 있으신 분들 조언 부탁드려요!")
                .anonymousAuthor("익명567")
                .build();
        post5.increaseLikeCount();
        post5.increaseLikeCount();
        posts.add(communityPostRepository.save(post5));

        return posts;
    }

    /**
     * 샘플 댓글 생성
     */
    private int createComments(List<User> users, List<CommunityPost> posts) {
        int count = 0;

        // 게시글 1에 댓글
        CommunityPost post1 = posts.get(0);

        Comment comment1 = Comment.builder()
                .postId(post1.getId())
                .userId(users.get(1).getId())
                .content("축하드려요! 저도 곧 시도해볼게요")
                .anonymousAuthor("익명111")
                .build();
        commentRepository.save(comment1);
        post1.increaseCommentCount();
        communityPostRepository.save(post1);
        count++;

        Comment comment2 = Comment.builder()
                .postId(post1.getId())
                .userId(users.get(0).getId())
                .content("감사합니다! 화이팅하세요~")
                .anonymousAuthor("익명123") // 원글 작성자
                .build();
        commentRepository.save(comment2);
        post1.increaseCommentCount();
        communityPostRepository.save(post1);
        count++;

        // 게시글 2에 댓글
        CommunityPost post2 = posts.get(1);

        Comment comment3 = Comment.builder()
                .postId(post2.getId())
                .userId(users.get(0).getId())
                .content("저희도 그랬어요. 수면환경을 어둡게 하니까 조금 나아졌어요.")
                .anonymousAuthor("익명222")
                .build();
        commentRepository.save(comment3);
        post2.increaseCommentCount();
        communityPostRepository.save(post2);
        count++;

        Comment comment4 = Comment.builder()
                .postId(post2.getId())
                .userId(users.get(1).getId())
                .content("백색소음도 도움이 될 수 있어요!")
                .anonymousAuthor("익명333")
                .build();
        commentRepository.save(comment4);
        post2.increaseCommentCount();
        communityPostRepository.save(post2);
        count++;

        // 게시글 3에 댓글
        CommunityPost post3 = posts.get(2);

        Comment comment5 = Comment.builder()
                .postId(post3.getId())
                .userId(users.get(1).getId())
                .content("수유 전후로 체중 재보시면 알 수 있어요")
                .anonymousAuthor("익명444")
                .build();
        commentRepository.save(comment5);
        post3.increaseCommentCount();
        communityPostRepository.save(post3);
        count++;

        return count;
    }
}
