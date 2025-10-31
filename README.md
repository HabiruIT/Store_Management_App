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

## 📂 Cấu trúc thư mục (Frontend)
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── models/
├── services/
│   └── api/
├── screens/
│   ├── dashboard/
│   ├── products/
│   ├── orders/
│   ├── customers/
│   └── login/
└── widgets/
```
---

## ⚙️ Cấu trúc API (Backend)
```
Controllers/
├── AuthController.cs
├── ProductController.cs
├── OrderController.cs
├── CustomerController.cs
└── ReportController.cs
```

Mỗi controller tương ứng với một module trong ứng dụng và tuân thủ chuẩn RESTful:
- GET /api/products → Lấy danh sách sản phẩm  
- POST /api/products → Tạo sản phẩm mới  
- PUT /api/products/{id} → Cập nhật sản phẩm  
- DELETE /api/products/{id} → Xóa sản phẩm  

---

## 🧰 Cách cài đặt và chạy dự án

### 1️⃣ Clone project

git clone https://github.com/<your-username>/store_management.git
cd store_management

### 2️⃣ Chạy backend (ASP.NET Core API)

cd backend
dotnet restore
dotnet ef database update
dotnet run

### 3️⃣ Cấu hình API URL cho Flutter

Tạo file .env trong thư mục flutter_app:

API_URL='http://[IP]:5085/api/'
BASE_HOST=http://[IP]:5085

### 4️⃣ Chạy Flutter app

cd flutter_app
flutter pub get
flutter run

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
