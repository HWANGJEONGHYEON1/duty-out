-- 개월별 스케줄 템플릿 초기 데이터
-- Wake Window(깨어있는 시간) 및 낮잠 시간 기준표

-- 3-4개월: 낮잠 3-4회
INSERT INTO schedule_templates (age_months, nap_count, total_sleep_hours, description, created_at, modified_at)
VALUES (3, 4, 14.0, '3-4개월: 낮잠 4회, 짧은 Wake Window', NOW(), NOW());

INSERT INTO template_wake_windows (template_id, minutes, sequence)
VALUES (1, 90, 0),  -- 깨시1: 1.5시간
       (1, 90, 1),  -- 깨시2: 1.5시간
       (1, 120, 2), -- 깨시3: 2시간
       (1, 120, 3), -- 깨시4: 2시간
       (1, 120, 4); -- 마지막 깨시: 2시간

INSERT INTO template_nap_durations (template_id, minutes, sequence)
VALUES (1, 60, 0),  -- 낮잠1: 1시간
       (1, 90, 1),  -- 낮잠2: 1.5시간
       (1, 90, 2),  -- 낮잠3: 1.5시간
       (1, 45, 3);  -- 낮잠4: 45분

-- 5-6개월: 낮잠 3회
INSERT INTO schedule_templates (age_months, nap_count, total_sleep_hours, description, created_at, modified_at)
VALUES (5, 3, 13.5, '5-6개월: 낮잠 3회, 점차 늘어나는 Wake Window', NOW(), NOW());

INSERT INTO template_wake_windows (template_id, minutes, sequence)
VALUES (2, 120, 0),  -- 깨시1: 2시간
       (2, 150, 1),  -- 깨시2: 2.5시간
       (2, 150, 2),  -- 깨시3: 2.5시간
       (2, 180, 3);  -- 마지막 깨시: 3시간

INSERT INTO template_nap_durations (template_id, minutes, sequence)
VALUES (2, 90, 0),   -- 낮잠1: 1.5시간
       (2, 90, 1),   -- 낮잠2: 1.5시간
       (2, 60, 2);   -- 낮잠3: 1시간

-- 7-8개월: 낮잠 2-3회
INSERT INTO schedule_templates (age_months, nap_count, total_sleep_hours, description, created_at, modified_at)
VALUES (7, 2, 12.5, '7-8개월: 낮잠 2회로 전환 시작', NOW(), NOW());

INSERT INTO template_wake_windows (template_id, minutes, sequence)
VALUES (3, 150, 0),  -- 깨시1: 2.5시간
       (3, 180, 1),  -- 깨시2: 3시간
       (3, 210, 2);  -- 마지막 깨시: 3.5시간

INSERT INTO template_nap_durations (template_id, minutes, sequence)
VALUES (3, 90, 0),   -- 낮잠1: 1.5시간
       (3, 90, 1);   -- 낮잠2: 1.5시간

-- 9-11개월: 낮잠 2회
INSERT INTO schedule_templates (age_months, nap_count, total_sleep_hours, description, created_at, modified_at)
VALUES (9, 2, 12.0, '9-11개월: 안정적인 2회 낮잠', NOW(), NOW());

INSERT INTO template_wake_windows (template_id, minutes, sequence)
VALUES (4, 180, 0),  -- 깨시1: 3시간
       (4, 210, 1),  -- 깨시2: 3.5시간
       (4, 240, 2);  -- 마지막 깨시: 4시간

INSERT INTO template_nap_durations (template_id, minutes, sequence)
VALUES (4, 90, 0),   -- 낮잠1: 1.5시간
       (4, 90, 1);   -- 낮잠2: 1.5시간

-- 12-18개월: 낮잠 1-2회
INSERT INTO schedule_templates (age_months, nap_count, total_sleep_hours, description, created_at, modified_at)
VALUES (12, 2, 11.5, '12-18개월: 2회 낮잠 유지 또는 1회 전환', NOW(), NOW());

INSERT INTO template_wake_windows (template_id, minutes, sequence)
VALUES (5, 240, 0),  -- 깨시1: 4시간
       (5, 300, 1),  -- 깨시2: 5시간
       (5, 240, 2);  -- 마지막 깨시: 4시간

INSERT INTO template_nap_durations (template_id, minutes, sequence)
VALUES (5, 60, 0),   -- 낮잠1: 1시간
       (5, 90, 1);   -- 낮잠2: 1.5시간

-- 18-24개월: 낮잠 1회
INSERT INTO schedule_templates (age_months, nap_count, total_sleep_hours, description, created_at, modified_at)
VALUES (18, 1, 11.0, '18-24개월: 낮잠 1회로 전환', NOW(), NOW());

INSERT INTO template_wake_windows (template_id, minutes, sequence)
VALUES (6, 300, 0),  -- 깨시1: 5시간
       (6, 300, 1);  -- 마지막 깨시: 5시간

INSERT INTO template_nap_durations (template_id, minutes, sequence)
VALUES (6, 120, 0);  -- 낮잠1: 2시간
