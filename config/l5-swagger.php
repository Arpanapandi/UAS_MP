<?php

return [
    'default' => 'default',
    'documentations' => [
        'default' => [
            'api' => [
                'title' => 'API Peminjaman Barang',
                'version' => '1.0.0',
                'description' => 'REST API untuk aplikasi peminjaman barang dengan multi user (admin dan peminjam)',
            ],
            'routes' => [
                'api' => 'api/documentation',
            ],
            'paths' => [
                'use_absolute_path' => env('L5_SWAGGER_USE_ABSOLUTE_PATH', false),
                'docs_json' => 'api-docs.json',
                'docs_yaml' => 'api-docs.yaml',
                'format_to_use' => env('L5_SWAGGER_FORMAT_TO_USE', 'json'),
                'annotations' => [
                    base_path('app'),
                ],
            ],
        ],
    ],
    'defaults' => [
        'routes' => [
            'api' => 'api/documentation',
        ],
        'paths' => [
            'use_absolute_path' => env('L5_SWAGGER_USE_ABSOLUTE_PATH', false),
            'docs_json' => 'api-docs.json',
            'docs_yaml' => 'api-docs.yaml',
            'format_to_use' => env('L5_SWAGGER_FORMAT_TO_USE', 'json'),
            'annotations' => [
                base_path('app'),
            ],
        ],
    ],
    'constants' => [
        'L5_SWAGGER_CONST_HOST' => env('L5_SWAGGER_CONST_HOST', 'http://localhost:8000/api'),
    ],
    'ui' => [
        'default' => 'swagger',
        'swagger' => [
            'path' => 'api/documentation',
        ],
        'redoc' => [
            'path' => 'api/redoc',
        ],
    ],
];

