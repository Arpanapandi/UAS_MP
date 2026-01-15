<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ApiDocsController extends Controller
{
    /**
     * Generate OpenAPI JSON specification
     */
    public function index()
    {
        $baseUrl = url('/api');
        
        $spec = [
            'openapi' => '3.0.0',
            'info' => [
                'title' => 'API Peminjaman Barang',
                'version' => '1.0.0',
                'description' => 'REST API untuk aplikasi peminjaman barang dengan multi user (admin dan peminjam). API ini digunakan untuk menjembatani aplikasi Flutter dengan database MySQL.',
                'contact' => [
                    'email' => 'admin@example.com'
                ]
            ],
            'servers' => [
                [
                    'url' => $baseUrl,
                    'description' => 'Local Development Server'
                ]
            ],
            'components' => [
                'securitySchemes' => [
                    'bearerAuth' => [
                        'type' => 'http',
                        'scheme' => 'bearer',
                        'bearerFormat' => 'JWT',
                        'description' => 'Masukkan token yang didapat dari endpoint /login. Format: Bearer {token}'
                    ]
                ],
                'schemas' => [
                    'Barang' => [
                        'type' => 'object',
                        'properties' => [
                            'id' => ['type' => 'integer', 'example' => 1],
                            'nama_barang' => ['type' => 'string', 'example' => 'Laptop'],
                            'stok' => ['type' => 'integer', 'example' => 10],
                            'keterangan' => ['type' => 'string', 'nullable' => true, 'example' => 'Laptop untuk keperluan kerja'],
                            'created_at' => ['type' => 'string', 'format' => 'date-time'],
                            'updated_at' => ['type' => 'string', 'format' => 'date-time']
                        ]
                    ],
                    'User' => [
                        'type' => 'object',
                        'properties' => [
                            'id' => ['type' => 'integer', 'example' => 1],
                            'name' => ['type' => 'string', 'example' => 'Admin'],
                            'email' => ['type' => 'string', 'example' => 'admin@example.com'],
                            'role' => ['type' => 'string', 'enum' => ['admin', 'peminjam'], 'example' => 'admin']
                        ]
                    ],
                    'Peminjaman' => [
                        'type' => 'object',
                        'properties' => [
                            'id' => ['type' => 'integer', 'example' => 1],
                            'user_id' => ['type' => 'integer', 'example' => 2],
                            'barang_id' => ['type' => 'integer', 'example' => 1],
                            'tanggal_pinjam' => ['type' => 'string', 'format' => 'date', 'example' => '2024-01-15'],
                            'status' => ['type' => 'string', 'enum' => ['dipinjam', 'dikembalikan'], 'example' => 'dipinjam'],
                            'user' => ['$ref' => '#/components/schemas/User'],
                            'barang' => ['$ref' => '#/components/schemas/Barang'],
                            'created_at' => ['type' => 'string', 'format' => 'date-time'],
                            'updated_at' => ['type' => 'string', 'format' => 'date-time']
                        ]
                    ],
                    'SuccessResponse' => [
                        'type' => 'object',
                        'properties' => [
                            'status' => ['type' => 'boolean', 'example' => true],
                            'message' => ['type' => 'string', 'example' => 'Success'],
                            'data' => ['type' => 'object']
                        ]
                    ],
                    'ErrorResponse' => [
                        'type' => 'object',
                        'properties' => [
                            'status' => ['type' => 'boolean', 'example' => false],
                            'message' => ['type' => 'string', 'example' => 'Error message']
                        ]
                    ]
                ]
            ],
            'paths' => [
                '/login' => [
                    'post' => [
                        'tags' => ['Authentication'],
                        'summary' => 'Login user',
                        'description' => 'Login untuk mendapatkan token authentication. Token digunakan untuk mengakses endpoint yang memerlukan autentikasi.',
                        'requestBody' => [
                            'required' => true,
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        'type' => 'object',
                                        'required' => ['email', 'password'],
                                        'properties' => [
                                            'email' => ['type' => 'string', 'format' => 'email', 'example' => 'admin@example.com'],
                                            'password' => ['type' => 'string', 'format' => 'password', 'example' => 'password']
                                        ]
                                    ],
                                    'examples' => [
                                        'default' => [
                                            'summary' => 'Login Admin',
                                            'value' => [
                                                'email' => 'admin@example.com',
                                                'password' => 'password'
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ],
                        'responses' => [
                            '200' => [
                                'description' => 'Login berhasil',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'status' => ['type' => 'boolean', 'example' => true],
                                                'token' => ['type' => 'string', 'example' => '1|xxxxxxxxxxxxx'],
                                                'user' => ['$ref' => '#/components/schemas/User']
                                            ]
                                        ],
                                        'example' => [
                                            'status' => true,
                                            'token' => '1|xxxxxxxxxxxxx',
                                            'user' => [
                                                'id' => 1,
                                                'name' => 'Admin',
                                                'email' => 'admin@example.com',
                                                'role' => 'admin'
                                            ]
                                        ]
                                    ]
                                ]
                            ],
                            '401' => [
                                'description' => 'Email atau password salah',
                                'content' => [
                                    'application/json' => [
                                        'schema' => ['$ref' => '#/components/schemas/ErrorResponse']
                                    ]
                                ]
                            ]
                        ]
                    ]
                ],
                '/register' => [
                    'post' => [
                        'tags' => ['Authentication'],
                        'summary' => 'Register peminjam baru',
                        'description' => 'Registrasi user baru. Role otomatis diset sebagai \'peminjam\' oleh backend. Frontend tidak boleh mengirim role.',
                        'requestBody' => [
                            'required' => true,
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        'type' => 'object',
                                        'required' => ['name', 'email', 'password'],
                                        'properties' => [
                                            'name' => ['type' => 'string', 'example' => 'John Doe'],
                                            'email' => ['type' => 'string', 'format' => 'email', 'example' => 'john@example.com'],
                                            'password' => ['type' => 'string', 'format' => 'password', 'example' => 'password123', 'minLength' => 8]
                                        ]
                                    ],
                                    'examples' => [
                                        'default' => [
                                            'summary' => 'Register Peminjam',
                                            'value' => [
                                                'name' => 'John Doe',
                                                'email' => 'john@example.com',
                                                'password' => 'password123'
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ],
                        'responses' => [
                            '201' => [
                                'description' => 'Registrasi berhasil',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'status' => ['type' => 'boolean', 'example' => true],
                                                'message' => ['type' => 'string', 'example' => 'Registrasi berhasil.'],
                                                'token' => ['type' => 'string', 'example' => '2|xxxxxxxxxxxxx'],
                                                'user' => ['$ref' => '#/components/schemas/User']
                                            ]
                                        ]
                                    ]
                                ]
                            ],
                            '422' => ['description' => 'Validation error']
                        ]
                    ]
                ],
                '/logout' => [
                    'post' => [
                        'tags' => ['Authentication'],
                        'summary' => 'Logout user',
                        'description' => 'Logout dan hapus token yang sedang digunakan',
                        'security' => [['bearerAuth' => []]],
                        'responses' => [
                            '200' => [
                                'description' => 'Logout berhasil',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'status' => ['type' => 'boolean', 'example' => true],
                                                'message' => ['type' => 'string', 'example' => 'Logout berhasil.']
                                            ]
                                        ]
                                    ]
                                ]
                            ],
                            '401' => ['description' => 'Unauthorized']
                        ]
                    ]
                ],
                '/barang' => [
                    'get' => [
                        'tags' => ['Barang'],
                        'summary' => 'Get all barang',
                        'description' => 'Mendapatkan semua data barang. Hanya admin yang bisa mengakses endpoint ini.',
                        'security' => [['bearerAuth' => []]],
                        'responses' => [
                            '200' => [
                                'description' => 'Data barang berhasil diambil',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'status' => ['type' => 'boolean', 'example' => true],
                                                'message' => ['type' => 'string', 'example' => 'Data barang berhasil diambil.'],
                                                'data' => [
                                                    'type' => 'array',
                                                    'items' => ['$ref' => '#/components/schemas/Barang']
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ],
                            '401' => ['description' => 'Unauthorized'],
                            '403' => ['description' => 'Forbidden - Hanya admin yang bisa mengakses']
                        ]
                    ],
                    'post' => [
                        'tags' => ['Barang'],
                        'summary' => 'Create barang baru',
                        'description' => 'Menambahkan barang baru ke database. Hanya admin yang bisa mengakses endpoint ini.',
                        'security' => [['bearerAuth' => []]],
                        'requestBody' => [
                            'required' => true,
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        'type' => 'object',
                                        'required' => ['nama_barang', 'stok'],
                                        'properties' => [
                                            'nama_barang' => ['type' => 'string', 'example' => 'Laptop'],
                                            'stok' => ['type' => 'integer', 'example' => 10, 'minimum' => 0],
                                            'keterangan' => ['type' => 'string', 'nullable' => true, 'example' => 'Laptop untuk keperluan kerja']
                                        ]
                                    ],
                                    'examples' => [
                                        'default' => [
                                            'summary' => 'Create Barang',
                                            'value' => [
                                                'nama_barang' => 'Laptop',
                                                'stok' => 10,
                                                'keterangan' => 'Laptop untuk keperluan kerja'
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ],
                        'responses' => [
                            '201' => [
                                'description' => 'Barang berhasil ditambahkan',
                                'content' => [
                                    'application/json' => [
                                        'schema' => ['$ref' => '#/components/schemas/SuccessResponse']
                                    ]
                                ]
                            ],
                            '403' => ['description' => 'Forbidden - Hanya admin yang bisa mengakses'],
                            '422' => ['description' => 'Validation error']
                        ]
                    ]
                ],
                '/barang/{id}' => [
                    'get' => [
                        'tags' => ['Barang'],
                        'summary' => 'Get barang by ID',
                        'description' => 'Mendapatkan data barang berdasarkan ID. Hanya admin yang bisa mengakses endpoint ini.',
                        'security' => [['bearerAuth' => []]],
                        'parameters' => [
                            [
                                'name' => 'id',
                                'in' => 'path',
                                'required' => true,
                                'schema' => ['type' => 'integer'],
                                'example' => 1
                            ]
                        ],
                        'responses' => [
                            '200' => [
                                'description' => 'Data barang berhasil diambil',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'status' => ['type' => 'boolean', 'example' => true],
                                                'message' => ['type' => 'string'],
                                                'data' => ['$ref' => '#/components/schemas/Barang']
                                            ]
                                        ]
                                    ]
                                ]
                            ],
                            '404' => ['description' => 'Barang tidak ditemukan'],
                            '403' => ['description' => 'Forbidden']
                        ]
                    ],
                    'put' => [
                        'tags' => ['Barang'],
                        'summary' => 'Update barang',
                        'description' => 'Update data barang berdasarkan ID. Hanya admin yang bisa mengakses endpoint ini.',
                        'security' => [['bearerAuth' => []]],
                        'parameters' => [
                            [
                                'name' => 'id',
                                'in' => 'path',
                                'required' => true,
                                'schema' => ['type' => 'integer']
                            ]
                        ],
                        'requestBody' => [
                            'required' => true,
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        'type' => 'object',
                                        'required' => ['nama_barang', 'stok'],
                                        'properties' => [
                                            'nama_barang' => ['type' => 'string', 'example' => 'Laptop Updated'],
                                            'stok' => ['type' => 'integer', 'example' => 15, 'minimum' => 0],
                                            'keterangan' => ['type' => 'string', 'nullable' => true]
                                        ]
                                    ],
                                    'examples' => [
                                        'default' => [
                                            'summary' => 'Update Barang',
                                            'value' => [
                                                'nama_barang' => 'Laptop Updated',
                                                'stok' => 15,
                                                'keterangan' => 'Updated keterangan'
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ],
                        'responses' => [
                            '200' => [
                                'description' => 'Barang berhasil diupdate',
                                'content' => [
                                    'application/json' => [
                                        'schema' => ['$ref' => '#/components/schemas/SuccessResponse']
                                    ]
                                ]
                            ],
                            '404' => ['description' => 'Barang tidak ditemukan'],
                            '403' => ['description' => 'Forbidden']
                        ]
                    ],
                    'delete' => [
                        'tags' => ['Barang'],
                        'summary' => 'Delete barang',
                        'description' => 'Hapus data barang berdasarkan ID. Hanya admin yang bisa mengakses endpoint ini.',
                        'security' => [['bearerAuth' => []]],
                        'parameters' => [
                            [
                                'name' => 'id',
                                'in' => 'path',
                                'required' => true,
                                'schema' => ['type' => 'integer']
                            ]
                        ],
                        'responses' => [
                            '200' => [
                                'description' => 'Barang berhasil dihapus',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'status' => ['type' => 'boolean', 'example' => true],
                                                'message' => ['type' => 'string', 'example' => 'Barang berhasil dihapus.']
                                            ]
                                        ]
                                    ]
                                ]
                            ],
                            '404' => ['description' => 'Barang tidak ditemukan'],
                            '403' => ['description' => 'Forbidden']
                        ]
                    ]
                ],
                '/peminjaman' => [
                    'get' => [
                        'tags' => ['Peminjaman'],
                        'summary' => 'Get all peminjaman',
                        'description' => 'Mendapatkan semua data peminjaman. Admin bisa melihat semua peminjaman, peminjam hanya bisa melihat peminjaman miliknya sendiri. user_id otomatis diambil dari token login.',
                        'security' => [['bearerAuth' => []]],
                        'responses' => [
                            '200' => [
                                'description' => 'Data peminjaman berhasil diambil',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'status' => ['type' => 'boolean', 'example' => true],
                                                'message' => ['type' => 'string', 'example' => 'Data peminjaman berhasil diambil.'],
                                                'data' => [
                                                    'type' => 'array',
                                                    'items' => ['$ref' => '#/components/schemas/Peminjaman']
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ],
                            '401' => ['description' => 'Unauthorized']
                        ]
                    ],
                    'post' => [
                        'tags' => ['Peminjaman'],
                        'summary' => 'Create peminjaman baru',
                        'description' => 'Menambahkan peminjaman baru. user_id otomatis diambil dari token login. Stok barang otomatis berkurang jika status = \'dipinjam\'.',
                        'security' => [['bearerAuth' => []]],
                        'requestBody' => [
                            'required' => true,
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        'type' => 'object',
                                        'required' => ['barang_id', 'tanggal_pinjam', 'status'],
                                        'properties' => [
                                            'barang_id' => ['type' => 'integer', 'example' => 1],
                                            'tanggal_pinjam' => ['type' => 'string', 'format' => 'date', 'example' => '2024-01-15'],
                                            'status' => ['type' => 'string', 'enum' => ['dipinjam', 'dikembalikan'], 'example' => 'dipinjam']
                                        ]
                                    ],
                                    'examples' => [
                                        'default' => [
                                            'summary' => 'Create Peminjaman',
                                            'value' => [
                                                'barang_id' => 1,
                                                'tanggal_pinjam' => '2024-01-15',
                                                'status' => 'dipinjam'
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ],
                        'responses' => [
                            '201' => [
                                'description' => 'Peminjaman berhasil ditambahkan',
                                'content' => [
                                    'application/json' => [
                                        'schema' => ['$ref' => '#/components/schemas/SuccessResponse']
                                    ]
                                ]
                            ],
                            '400' => ['description' => 'Stok barang tidak tersedia'],
                            '404' => ['description' => 'Barang tidak ditemukan'],
                            '422' => ['description' => 'Validation error']
                        ]
                    ]
                ],
                '/peminjaman/{id}' => [
                    'get' => [
                        'tags' => ['Peminjaman'],
                        'summary' => 'Get peminjaman by ID',
                        'description' => 'Mendapatkan data peminjaman berdasarkan ID. Admin bisa melihat semua, peminjam hanya bisa melihat peminjaman miliknya sendiri.',
                        'security' => [['bearerAuth' => []]],
                        'parameters' => [
                            [
                                'name' => 'id',
                                'in' => 'path',
                                'required' => true,
                                'schema' => ['type' => 'integer']
                            ]
                        ],
                        'responses' => [
                            '200' => [
                                'description' => 'Data peminjaman berhasil diambil',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'status' => ['type' => 'boolean', 'example' => true],
                                                'message' => ['type' => 'string'],
                                                'data' => ['$ref' => '#/components/schemas/Peminjaman']
                                            ]
                                        ]
                                    ]
                                ]
                            ],
                            '403' => ['description' => 'Akses ditolak'],
                            '404' => ['description' => 'Peminjaman tidak ditemukan']
                        ]
                    ],
                    'put' => [
                        'tags' => ['Peminjaman'],
                        'summary' => 'Update peminjaman',
                        'description' => 'Update data peminjaman. Admin bisa update semua, peminjam hanya bisa update peminjaman miliknya. Jika status berubah dari \'dipinjam\' ke \'dikembalikan\', stok barang otomatis kembali.',
                        'security' => [['bearerAuth' => []]],
                        'parameters' => [
                            [
                                'name' => 'id',
                                'in' => 'path',
                                'required' => true,
                                'schema' => ['type' => 'integer']
                            ]
                        ],
                        'requestBody' => [
                            'required' => false,
                            'content' => [
                                'application/json' => [
                                    'schema' => [
                                        'type' => 'object',
                                        'properties' => [
                                            'barang_id' => ['type' => 'integer', 'example' => 1],
                                            'tanggal_pinjam' => ['type' => 'string', 'format' => 'date', 'example' => '2024-01-15'],
                                            'status' => ['type' => 'string', 'enum' => ['dipinjam', 'dikembalikan'], 'example' => 'dikembalikan']
                                        ]
                                    ],
                                    'examples' => [
                                        'default' => [
                                            'summary' => 'Update Peminjaman',
                                            'value' => [
                                                'barang_id' => 1,
                                                'tanggal_pinjam' => '2024-01-15',
                                                'status' => 'dikembalikan'
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ],
                        'responses' => [
                            '200' => [
                                'description' => 'Peminjaman berhasil diupdate',
                                'content' => [
                                    'application/json' => [
                                        'schema' => ['$ref' => '#/components/schemas/SuccessResponse']
                                    ]
                                ]
                            ],
                            '400' => ['description' => 'Stok barang tidak tersedia'],
                            '403' => ['description' => 'Akses ditolak'],
                            '404' => ['description' => 'Peminjaman tidak ditemukan']
                        ]
                    ],
                    'delete' => [
                        'tags' => ['Peminjaman'],
                        'summary' => 'Delete peminjaman',
                        'description' => 'Hapus data peminjaman. Admin bisa hapus semua, peminjam hanya bisa hapus peminjaman miliknya. Jika status = \'dipinjam\', stok barang otomatis dikembalikan.',
                        'security' => [['bearerAuth' => []]],
                        'parameters' => [
                            [
                                'name' => 'id',
                                'in' => 'path',
                                'required' => true,
                                'schema' => ['type' => 'integer']
                            ]
                        ],
                        'responses' => [
                            '200' => [
                                'description' => 'Peminjaman berhasil dihapus',
                                'content' => [
                                    'application/json' => [
                                        'schema' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'status' => ['type' => 'boolean', 'example' => true],
                                                'message' => ['type' => 'string', 'example' => 'Peminjaman berhasil dihapus.']
                                            ]
                                        ]
                                    ]
                                ]
                            ],
                            '403' => ['description' => 'Akses ditolak'],
                            '404' => ['description' => 'Peminjaman tidak ditemukan']
                        ]
                    ]
                ]
            ],
            'tags' => [
                [
                    'name' => 'Authentication',
                    'description' => 'Endpoint untuk autentikasi (login, register, logout)'
                ],
                [
                    'name' => 'Barang',
                    'description' => 'API untuk mengelola data barang. Hanya bisa diakses oleh admin.'
                ],
                [
                    'name' => 'Peminjaman',
                    'description' => 'API untuk mengelola data peminjaman. Admin bisa melihat semua, peminjam hanya bisa melihat peminjaman miliknya sendiri.'
                ]
            ]
        ];

        return response()->json($spec);
    }
}

