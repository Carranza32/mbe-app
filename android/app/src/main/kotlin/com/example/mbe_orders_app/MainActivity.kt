package com.example.mbe_orders_app

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * FlutterFragmentActivity es requerido por local_auth (huella/Face ID) en Android:
 * BiometricPrompt necesita una FragmentActivity para mostrar el diálogo.
 */
class MainActivity : FlutterFragmentActivity()
