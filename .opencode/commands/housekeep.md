---
description: Post-development maintenance — review files, direct branch release, learn from intent-first evidence, update project knowledge
---

# /housekeep — JavLuv Housekeeper

## Quick Reference

```
/housekeep review    → Xem danh sách files thay đổi để kiểm tra
/housekeep branch   → Tạo version branch trực tiếp (full snapshot, auto snapshot + push)
/housekeep learn     → Yêu cầu Manager synthesize handoff → tạo `learning-brief.md` dry-run → chỉ write sau khi brief được approve
/housekeep update    → Cập nhật PROJECT_STATUS + memory system
/housekeep full      → Chạy tuần tự tất cả 4 bước trên
/housekeep           → Mặc định = full
```

## Workflow Overview

| Step | Workflow | Chức năng | User approval |
|------|----------|-----------|---------------|
| 1 | **Review** | Scan git changes → phân loại → trình bày bảng | Chọn files approve/reject |
| 2 | **Branch** | Full snapshot release → auto snapshot + push + tạo version branch | Approve full snapshot scope |
| 3 | **Learn** | Intent-first analysis → `learning-brief.md` → optional write phase | Approve brief trước, rồi mới approve write phase |
| 4 | **Update** | Update PROJECT_STATUS.md + memory files | Approve changes |

## Usage Examples

```bash
# Sau khi JavLuvManager hoàn thành 1 feature:
/housekeep review
# → Xem tất cả files đã thay đổi, kiểm tra trước khi branch

/housekeep branch
# → Tạo release branch trực tiếp từ full snapshot (auto snapshot + push)

/housekeep learn
# → Housekeeper yêu cầu Manager synthesize `learn-handoff.md`, rồi tạo `learning-brief.md` làm dry-run output mặc định
# → Nếu cần hiểu sâu 1 concern implement cụ thể, Housekeeper mới hỏi thêm JavLuvSystemLibrary
# → Chỉ sau khi brief được approve mới được write skill/instinct/reference thật

/housekeep update
# → Cập nhật PROJECT_STATUS.md và memory system

# Làm tất cả cùng lúc:
/housekeep full
# → Review → Branch → Learn → Update (skip được từng bước)
```

## Vietnamese Aliases

Hỗ trợ từ khóa tiếng Việt:
- `xem` / `kiểm tra` → review
- `lưu` / `nhánh` / `tạo nhánh` / `release` → branch
- `học` → learn
- `cập nhật` → update
- `tất cả` → full

## Important Notes

- **User control**: Agent LUÔN hỏi trước khi thực hiện side effects
- **Isolation**: KHÔNG can thiệp vào JavLuvManager workflow
- **Idempotent**: Chạy lại an toàn, không tạo duplicate
- **Skills reused**: javluv-release-engineering, continuous-learning-v2, skill-creator, writing-skills
- **Learn template policy**: Skill updates dùng progressive disclosure + strict description ("Use when..." only, no workflow summary). Quality validated by writing-skills.
- **Learn evidence order**: ưu tiên `learn-handoff.md` → session/context artifacts → local diff/git notes → GitHub comments → memory/`PROJECT_STATUS.md`
- **Fallback mode**: nếu phải reconstruct chủ yếu từ diff/comments/memory, Housekeeper phải ghi rõ fallback mode và hạ confidence
- **Dry-run first**: output mặc định của `/housekeep learn` là `learning-brief.md`, không phải skill file
- **Write gate**: low-confidence run dừng ở brief hoặc candidate note; không auto-write. Skill/instinct/reference chỉ được write sau khi brief được approve
- **Run ownership**: Housekeeper owns `.tmp/housekeep/learn/{run-id}/`, tái sử dụng cùng `run-id` cho handoff → brief → optional write phase, và chỉ Housekeeper mới được offer cleanup khi learn workflow hoàn tất
- **Branch policy**: Luôn hiển thị Full Snapshot File Manifest trước khi chạy /housekeep branch, bằng cách chạy `python ".opencode/scripts/housekeep/full_snapshot_manifest.py"` từ repo root
