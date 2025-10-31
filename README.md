# 🏪 Store Management App

Ứng dụng **quản lý cửa hàng bán lẻ** được xây dựng với **Flutter** (frontend) và **ASP.NET Core Web API** (backend).  
Dự án giúp chủ cửa hàng **quản lý sản phẩm, đơn hàng, khách hàng, doanh thu và tồn kho** dễ dàng, mọi lúc, mọi nơi.

---

## 🚀 Tổng quan dự án

**Store Management App** hỗ trợ số hóa hoạt động kinh doanh bán lẻ, giúp tối ưu hiệu suất và giảm sai sót trong quản lý.  
Dự án gồm hai phần chính:

- **Frontend (Flutter)**: Ứng dụng di động / web hiển thị giao diện người dùng.  
- **Backend (ASP.NET Core Web API)**: Xử lý nghiệp vụ, xác thực, và cung cấp dữ liệu qua REST API.

---

## 🧩 Kiến trúc hệ thống

[Flutter App] ⇄ [ASP.NET Core API] ⇄ [SQL Server Database]

- **Flutter**: Viết bằng Dart 3.x, hỗ trợ Android, iOS, Web.  
- **ASP.NET Core 9.0 API**: Cung cấp các endpoint RESTful, xác thực JWT, tích hợp Entity Framework Core.  
- **Database**: SQL Server (hoặc Azure SQL / PostgreSQL tuỳ chọn).  
- **State Management**: Riverpod / Bloc.  
- **Authentication**: JSON Web Token (JWT).

---

## 🛠️ Công nghệ sử dụng

| Thành phần | Công nghệ |
|-------------|------------|
| Frontend | Flutter (Dart 3.x), Material Design 3 |
| Backend | ASP.NET Core 9.0 |
| Database | SQL Server |
| Authentication | JWT Bearer |
| API Docs | Swagger UI |
| Env Config | flutter_dotenv |
---

## 🧪 Các tính năng chính

- ✅ Đăng nhập / đăng xuất, phân quyền người dùng  
- 🛍️ Quản lý sản phẩm, danh mục, giá bán  
- 📦 Quản lý tồn kho 
- 🧾 Quản lý đơn hàng 
- 📈 Báo cáo doanh thu, biểu đồ thống kê  
- ☁️ Đồng bộ dữ liệu giữa thiết bị và máy chủ  
- 🔒 Bảo mật JWT và xác thực API  

---

## 🧠 Kế hoạch mở rộng

- [ ] Tích hợp QR/Barcode Scanner  
- [ ] Hỗ trợ đa chi nhánh  
- [ ] Giao diện quản trị web (Admin Dashboard)  
- [ ] Hỗ trợ đa ngôn ngữ (i18n)  
- [ ] Tích hợp AI gợi ý nhập hàng  

---

## 👨‍💻 Tác giả & đóng góp

- **Author:** Đặng Thịnh Đại
- **Email:** dangthinhdaiit@gmail.com

---

> _"Quản lý cửa hàng dễ dàng hơn, mọi lúc – mọi nơi!"_
