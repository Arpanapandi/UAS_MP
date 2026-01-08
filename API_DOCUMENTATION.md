# Dokumentasi API Peminjaman Barang

## Setup Awal

1. Install dependencies:
```bash
composer install
```

2. Copy file .env:
```bash
cp .env.example .env
```

3. Generate application key:
```bash
php artisan key:generate
```

4. Setup database di file .env:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=nama_database
DB_USERNAME=username
DB_PASSWORD=password
```

5. Jalankan migration:
```bash
php artisan migrate
```

6. Buat admin user:
```bash
php artisan db:seed --class=AdminSeeder
```

**Default Admin:**
- Email: `admin@example.com`
- Password: `password`

---

## Base URL
```
http://localhost:8000/api
```

---

## Endpoints

### 1. AUTHENTIKASI

#### Login
**POST** `/api/login`

**Request Body:**
```json
{
  "email": "admin@example.com",
  "password": "password"
}
```

**Response Success:**
```json
{
  "status": true,
  "token": "1|xxxxxxxxxxxxx",
  "user": {
    "id": 1,
    "name": "Admin",
    "email": "admin@example.com",
    "role": "admin"
  }
}
```

---

#### Registrasi (Peminjam)
**POST** `/api/register`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Note:** Role otomatis diset sebagai "peminjam" oleh backend.

**Response Success:**
```json
{
  "status": true,
  "message": "Registrasi berhasil.",
  "token": "2|xxxxxxxxxxxxx",
  "user": {
    "id": 2,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "peminjam"
  }
}
```

---

#### Logout
**POST** `/api/logout`

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "status": true,
  "message": "Logout berhasil."
}
```

---

### 2. BARANG (Admin Only)

**Semua endpoint barang memerlukan:**
- Authentication: `Bearer {token}`
- Role: `admin`

#### Get All Barang
**GET** `/api/barang`

**Response:**
```json
{
  "status": true,
  "message": "Data barang berhasil diambil.",
  "data": [
    {
      "id": 1,
      "nama_barang": "Laptop",
      "stok": 10,
      "keterangan": "Laptop untuk keperluan kerja",
      "created_at": "2024-01-01T00:00:00.000000Z",
      "updated_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

#### Get Barang by ID
**GET** `/api/barang/{id}`

---

#### Create Barang
**POST** `/api/barang`

**Request Body:**
```json
{
  "nama_barang": "Laptop",
  "stok": 10,
  "keterangan": "Laptop untuk keperluan kerja"
}
```

---

#### Update Barang
**PUT** `/api/barang/{id}`

**Request Body:**
```json
{
  "nama_barang": "Laptop Updated",
  "stok": 15,
  "keterangan": "Updated keterangan"
}
```

---

#### Delete Barang
**DELETE** `/api/barang/{id}`

---

### 3. PEMINJAMAN

**Semua endpoint peminjaman memerlukan:**
- Authentication: `Bearer {token}`

**Ketentuan:**
- Admin bisa melihat semua peminjaman
- Peminjam hanya bisa melihat peminjaman miliknya sendiri
- `user_id` otomatis diambil dari token login

#### Get All Peminjaman
**GET** `/api/peminjaman`

**Response (Admin):**
```json
{
  "status": true,
  "message": "Data peminjaman berhasil diambil.",
  "data": [
    {
      "id": 1,
      "user_id": 2,
      "barang_id": 1,
      "tanggal_pinjam": "2024-01-15",
      "status": "dipinjam",
      "created_at": "2024-01-01T00:00:00.000000Z",
      "updated_at": "2024-01-01T00:00:00.000000Z",
      "user": {
        "id": 2,
        "name": "John Doe",
        "email": "john@example.com"
      },
      "barang": {
        "id": 1,
        "nama_barang": "Laptop",
        "stok": 9
      }
    }
  ]
}
```

---

#### Create Peminjaman
**POST** `/api/peminjaman`

**Request Body:**
```json
{
  "barang_id": 1,
  "tanggal_pinjam": "2024-01-15",
  "status": "dipinjam"
}
```

**Note:** 
- Stok barang otomatis berkurang jika status = "dipinjam"
- Stok otomatis kembali jika status diubah menjadi "dikembalikan"

---

#### Get Peminjaman by ID
**GET** `/api/peminjaman/{id}`

---

#### Update Peminjaman
**PUT** `/api/peminjaman/{id}`

**Request Body:**
```json
{
  "status": "dikembalikan"
}
```

**Note:** Bisa update sebagian field saja.

---

#### Delete Peminjaman
**DELETE** `/api/peminjaman/{id}`

**Note:** Jika status = "dipinjam", stok akan dikembalikan otomatis.

---

## Response Error Format

```json
{
  "status": false,
  "message": "Pesan error"
}
```

**Status Code:**
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 422: Validation Error

---

## Testing dengan Postman/Thunder Client

1. **Login** untuk mendapatkan token
2. Copy token dari response
3. Set header di semua request berikutnya:
   ```
   Authorization: Bearer {token}
   Content-Type: application/json
   ```

---

## Catatan Penting

1. **Role Management:**
   - Backend yang menentukan role user
   - Registrasi otomatis set role = "peminjam"
   - Admin dibuat via seeder, bukan API publik

2. **Stok Management:**
   - Stok otomatis berkurang saat peminjaman dengan status "dipinjam"
   - Stok otomatis kembali saat status diubah menjadi "dikembalikan" atau saat peminjaman dihapus

3. **Security:**
   - Semua endpoint kecuali login & register memerlukan token
   - Endpoint barang hanya bisa diakses admin
   - Peminjam hanya bisa melihat/update/hapus peminjaman miliknya sendiri

