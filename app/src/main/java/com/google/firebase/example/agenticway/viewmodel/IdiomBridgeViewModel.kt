package com.google.firebase.example.agenticway.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.firebase.Firebase
import com.google.firebase.ai.ai
import com.google.firebase.ai.type.GenerativeBackend
import com.google.firebase.ai.type.content
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

/**
 * UI State for the Idiom Bridge screen.
 */
data class IdiomBridgeUiState(
    val britishIdiomInput: String = "",
    val brazilianIdiomOutput: String? = null,
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

/**
 * ViewModel managing the Idiom Bridge screen state and interactions.
 */
class IdiomBridgeViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(IdiomBridgeUiState())
    val uiState: StateFlow<IdiomBridgeUiState> = _uiState.asStateFlow()

    private val generativeModel by lazy {
        Firebase.ai(backend = GenerativeBackend.googleAI()).generativeModel(
            modelName = "gemini-3.5-flash-lite",
            systemInstruction = content {
                text(
                    "You are an expert idiom translator specializing in British English and Brazilian Portuguese. " +
                        "Given a British English idiom, provide the closest equivalent idiom in Brazilian Portuguese. " +
                        "Reply only with the Brazilian Portuguese idiom and no extra explanation."
                )
            }
        )
    }

    /**
     * Updates the user's input text for the British idiom.
     */
    fun onBritishIdiomChanged(newText: String) {
        _uiState.update { it.copy(britishIdiomInput = newText, errorMessage = null) }
    }

    /**
     * Translates the British idiom to its Brazilian equivalent.
     */
    fun onTranslateClicked() {
        val input = _uiState.value.britishIdiomInput.trim()
        if (input.isBlank() || _uiState.value.isLoading) return

        _uiState.update {
            it.copy(
                isLoading = true,
                errorMessage = null
            )
        }

        viewModelScope.launch {
            try {
                val prompt =
                    "Provide the closest Brazilian Portuguese idiom equivalent for the British idiom: \"$input\""
                val response = generativeModel.generateContent(prompt)
                val output = response.text?.trim()
                _uiState.update {
                    it.copy(
                        brazilianIdiomOutput = output,
                        isLoading = false,
                        errorMessage = if (output.isNullOrBlank()) {
                            "Could not find an equivalent idiom."
                        } else {
                            null
                        }
                    )
                }
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        errorMessage = e.localizedMessage ?: "Failed to translate idiom."
                    )
                }
            }
        }
    }
}

