<?php

namespace App\Models;

use MongoDB\Laravel\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'iduser',
        'nama',
        'email',
        'password',
        'role',
        'google_id'
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];
}
