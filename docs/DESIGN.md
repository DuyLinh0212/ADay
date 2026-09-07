---
name: ADay
description: Plan Today · A Better Tomorrow
colors:
  brand-navy: "#0A3768"
  action-blue: "#168AF2"
  sky-cyan: "#27BCEB"
  progress-teal: "#0EB8AC"
  success-mint: "#20C99A"
  sunrise-gold: "#FFB52E"
  cancel-coral: "#F0525E"
  canvas: "#F7FCFF"
  surface: "#FFFFFF"
  cool-surface: "#EEF7FD"
  muted-ink: "#6683A5"
  divider: "#DCE9F3"
typography:
  headline:
    fontFamily: "Be Vietnam Pro, system-ui, sans-serif"
    fontSize: "28px"
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: "-0.02em"
  title:
    fontFamily: "Be Vietnam Pro, system-ui, sans-serif"
    fontSize: "20px"
    fontWeight: 700
    lineHeight: 1.3
  body:
    fontFamily: "Be Vietnam Pro, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Be Vietnam Pro, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.35
rounded:
  control: "12px"
  surface: "16px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.action-blue}"
    textColor: "{colors.surface}"
    rounded: "{rounded.control}"
    padding: "14px 20px"
    height: "52px"
  button-secondary:
    backgroundColor: "{colors.cool-surface}"
    textColor: "{colors.action-blue}"
    rounded: "{rounded.control}"
    padding: "12px 16px"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.brand-navy}"
    rounded: "{rounded.surface}"
    padding: "16px"
  input:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.brand-navy}"
    rounded: "{rounded.control}"
    padding: "14px 16px"
---

# Design System: ADay

## Overview

**Creative North Star: "Bình minh có kế hoạch"**

ADay mang cảm giác mở cửa sổ vào một buổi sáng trong trẻo: người dùng nhìn thấy việc cần làm, tiến độ và bước tiếp theo mà không bị áp lực bởi mật độ hay ngôn ngữ phán xét. Hệ thống dùng nền sáng lạnh, mực xanh navy và những dải xanh lam–teal gợi bầu trời, núi và đường chân trời trong bộ ảnh tham chiếu.

Mỗi màn hình ưu tiên một hành động chính và cho phép quét nội dung theo trật tự hôm nay → tiến độ → nhiệm vụ → bước kế tiếp. Chuyển động chỉ xác nhận thay đổi trạng thái trong 150–250ms; không có trình diễn khi tải trang. Giao diện tuyệt đối không giống dashboard doanh nghiệp tối, không dùng gamification gây áp lực, hiệu ứng kính trang trí, thẻ lồng thẻ hoặc minh họa nguệch ngoạc.

**Key Characteristics:**

- Sáng, rõ và giàu khoảng thở nhưng vẫn hiển thị đủ thông tin.
- Navy tạo độ tin cậy; xanh lam và teal chỉ dẫn hành động và tiến độ.
- Trạng thái luôn có biểu tượng hoặc nhãn, không phụ thuộc riêng vào màu.
- Một từ vựng component thống nhất trên toàn bộ ứng dụng.

## Colors

Palette là hành trình từ bầu trời xanh sang mặt đất teal, với vàng bình minh và coral chỉ dành cho trạng thái cần chú ý.

### Primary

- **Action Blue** (`action-blue`): hành động chính, tab đang chọn, liên kết và focus ring.
- **Brand Navy** (`brand-navy`): tiêu đề, nội dung quan trọng và icon trung tính có độ tương phản cao.

### Secondary

- **Progress Teal** (`progress-teal`): vòng tiến độ, trạng thái hoàn tất và biểu đồ tích cực.
- **Sky Cyan** (`sky-cyan`): chuyển tiếp trong hero, dữ liệu bổ trợ và điểm nhấn bầu trời.

### Tertiary

- **Sunrise Gold** (`sunrise-gold`): nhắc nhở, tạm hoãn và lời gọi chuẩn bị ngày mai.
- **Cancel Coral** (`cancel-coral`): hủy mục tiêu và lỗi cần xử lý; không dùng cho trang trí.

### Neutral

- **Morning Canvas** (`canvas`): nền ứng dụng sáng lạnh.
- **Clear Surface** (`surface`): vùng nội dung chính.
- **Cool Surface** (`cool-surface`): nhóm điều khiển, trạng thái chưa chọn và nền phụ.
- **Muted Ink** (`muted-ink`): metadata và mô tả phụ, vẫn phải đạt tương phản AA.
- **Divider Mist** (`divider`): đường phân cách mảnh 1px.

**The Earned Color Rule.** Màu bão hòa chỉ xuất hiện khi truyền đạt hành động, trạng thái hoặc tiến độ; trạng thái không hoạt động luôn dùng neutral.

**The More-Than-Color Rule.** Hoàn thành, hoãn, hủy và quá hạn luôn có icon hoặc nhãn chữ bên cạnh màu.

## Typography

**Display Font:** Be Vietnam Pro (với system-ui fallback)  
**Body Font:** Be Vietnam Pro (với system-ui fallback)

**Character:** Một sans humanist duy nhất giữ tiếng Việt rõ ở cỡ nhỏ, thân thiện ở tiêu đề và nhất quán với giao diện sản phẩm. Không dùng display font trong label, nút hoặc dữ liệu.

### Hierarchy

- **Headline** (700, 28px, 1.25): lời chào và tiêu đề màn hình; letter-spacing không thấp hơn -0.02em.
- **Title** (700, 20px, 1.3): tiêu đề nhóm và mục tiêu.
- **Body** (400, 16px, 1.5): mô tả và nội dung; đoạn văn tối đa 65–75 ký tự mỗi dòng.
- **Label** (600, 14px, 1.35): nút, chip, metadata quan trọng; dùng sentence case.

**The Vietnamese First Rule.** Mọi thành phần phải được thử với dấu tiếng Việt và cỡ chữ hệ thống lớn; không cắt dòng để giữ chiều cao giả định.

## Elevation

ADay dùng tonal layering làm chiều sâu chính. Shadow chỉ là bóng môi trường nhẹ cho vùng nổi như bottom navigation hoặc panel hành động; card thường dùng nền rõ và khoảng cách, không ghép border 1px với shadow mờ rộng.

### Shadow Vocabulary

- **Ambient Low** (`0 4px 8px rgba(28, 91, 132, 0.10)`): bottom navigation và panel nổi cần tách khỏi canvas.
- **Focus Halo** (`0 0 0 3px rgba(22, 138, 242, 0.24)`): focus keyboard hoặc accessibility switch control.

**The Layer Before Shadow Rule.** Tạo phân cấp bằng canvas → cool surface → surface trước; chỉ thêm shadow khi thành phần thực sự nằm trên lớp khác.

## Components

### Buttons

- **Shape:** bo cong có kiểm soát (12px); chỉ chip và nút icon tròn mới dùng pill.
- **Primary:** Action Blue với chữ trắng, cao tối thiểu 52px và vùng chạm tối thiểu 44x44.
- **Hover / Focus:** đổi sắc độ trong 180ms; focus hiển thị Focus Halo; loading giữ nguyên kích thước.
- **Secondary:** Cool Surface với chữ Action Blue; destructive dùng Cancel Coral và luôn có nhãn rõ.

### Chips

- **Style:** pill nhỏ cho “Cả ngày”, thời gian và bộ lọc; nền neutral khi chưa chọn.
- **State:** được chọn dùng tint của trạng thái cùng icon hoặc chữ; không dùng màu bão hòa cho inactive.

### Cards / Containers

- **Corner Style:** 16px, không vượt 16px cho surface lớn.
- **Background:** Clear Surface hoặc Cool Surface; hero tiến độ có thể dùng dải Action Blue → Progress Teal vì mang dữ liệu trọng tâm.
- **Shadow Strategy:** flat mặc định; Ambient Low chỉ cho lớp nổi.
- **Border:** Divider Mist 1px chỉ khi cần tách điều khiển; không kết hợp với bóng rộng.
- **Internal Padding:** 16–24px tùy mật độ.

### Inputs / Fields

- **Style:** nền Canvas, stroke Divider Mist, bo 12px, label nằm ngoài hoặc rõ bên trong.
- **Focus:** stroke Action Blue cùng Focus Halo.
- **Error / Disabled:** lỗi dùng Cancel Coral kèm thông báo; disabled giảm nhấn nhưng văn bản vẫn đọc được.

### Navigation

Bottom navigation có bốn mục Trang chủ, Lịch, Thống kê, Hồ sơ. Mục đang chọn dùng Action Blue và chỉ báo ngắn; các mục khác dùng Muted Ink. Mỗi mục có icon nhất quán, nhãn rõ và vùng chạm tối thiểu 44x44.

### Progress Summary

Khối chữ ký kết hợp vòng hoàn thành, số lượng nhiệm vụ và breakdown trạng thái. Tỷ lệ phải lấy từ cùng nguồn dữ liệu với danh sách; 0/0 hiển thị 0% thay vì lỗi chia cho 0.

## Do's and Don'ts

### Do:

- **Do** đặt hôm nay và hành động kế tiếp ở vùng dễ thấy nhất.
- **Do** dùng radius 12px cho control, 16px cho surface và 999px chỉ cho pill.
- **Do** dùng Action Blue cho hành động chính, Progress Teal cho hoàn thành, Sunrise Gold cho hoãn và Cancel Coral cho hủy.
- **Do** cung cấp trạng thái default, pressed, focus, disabled, loading và error cho mọi điều khiển.
- **Do** để layout tự tăng chiều cao khi chữ lớn hoặc tiếng Việt xuống dòng.

### Don't:

- **Don't** dùng giao diện tối hoặc khô cứng như công cụ quản trị doanh nghiệp.
- **Don't** dùng gamification gây áp lực, chuỗi thành tích mang tính trừng phạt hoặc cảnh báo đỏ quá mức.
- **Don't** dùng dashboard dày đặc số liệu, hiệu ứng kính trang trí, thẻ lồng thẻ hoặc hình minh họa nguệch ngoạc.
- **Don't** biến việc hoãn hoặc hủy thành thất bại đạo đức.
- **Don't** dùng side-stripe accent, gradient text, card bo từ 32px trở lên hoặc border 1px đi cùng shadow mờ rộng.
