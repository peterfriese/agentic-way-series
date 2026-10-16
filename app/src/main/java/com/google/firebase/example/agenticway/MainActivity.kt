package com.google.firebase.example.agenticway

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import com.google.firebase.Firebase
import com.google.firebase.appcheck.appCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import com.google.firebase.example.agenticway.ui.screens.IdiomBridgeScreen
import com.google.firebase.example.agenticway.ui.theme.AgenticWayTheme
import com.google.firebase.example.agenticway.viewmodel.IdiomBridgeViewModel
import com.google.firebase.initialize

class MainActivity : ComponentActivity() {

    private val viewModel: IdiomBridgeViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Firebase.initialize(context = this)
        Firebase.appCheck.installAppCheckProviderFactory(
            DebugAppCheckProviderFactory.getInstance(),
        )
        enableEdgeToEdge()
        setContent {
            AgenticWayTheme {
                IdiomBridgeScreen(viewModel = viewModel)
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun IdiomBridgeScreenPreview() {
    AgenticWayTheme {
        IdiomBridgeScreen(viewModel = IdiomBridgeViewModel())
    }
}