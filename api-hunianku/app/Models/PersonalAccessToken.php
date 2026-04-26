<?php

namespace App\Models;

use Laravel\Sanctum\PersonalAccessToken as SanctumToken;
use MongoDB\Laravel\Eloquent\DocumentModel;

class PersonalAccessToken extends SanctumToken
{
    // Trait ini yang memungkinkan token Sanctum disimpan dalam format MongoDB
    use DocumentModel;
}
