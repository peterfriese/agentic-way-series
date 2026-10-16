package com.google.firebase.example.agenticway.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.firebase.example.agenticway.R
import com.google.firebase.example.agenticway.ui.theme.BrazilianBadgeBackground
import com.google.firebase.example.agenticway.ui.theme.BrazilianBadgeText
import com.google.firebase.example.agenticway.ui.theme.BritishBadgeBackground
import com.google.firebase.example.agenticway.ui.theme.BritishBadgeText
import com.google.firebase.example.agenticway.ui.theme.EmptyStateCircleBackground
import com.google.firebase.example.agenticway.ui.theme.EmptyStateIconTint
import com.google.firebase.example.agenticway.ui.theme.HeaderIconBackground
import com.google.firebase.example.agenticway.ui.theme.HeaderIconTint
import com.google.firebase.example.agenticway.ui.theme.IdiomScreenBackground
import com.google.firebase.example.agenticway.ui.theme.InputCardBackground
import com.google.firebase.example.agenticway.ui.theme.OutputCardBackground
import com.google.firebase.example.agenticway.ui.theme.TextPrimary
import com.google.firebase.example.agenticway.ui.theme.TextSecondary
import com.google.firebase.example.agenticway.ui.theme.TranslateButtonBackground
import com.google.firebase.example.agenticway.ui.theme.TranslateButtonContent
import com.google.firebase.example.agenticway.viewmodel.IdiomBridgeViewModel

@Composable
fun IdiomBridgeScreen(
    viewModel: IdiomBridgeViewModel,
    modifier: Modifier = Modifier
) {
    val uiState by viewModel.uiState.collectAsState()

    Surface(
        modifier = modifier.fillMaxSize(),
        color = IdiomScreenBackground
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
        ) {
            // Header
            IdiomBridgeHeader(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 12.dp)
            )

            // Cards Column
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(start = 16.dp, end = 16.dp, bottom = 16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Input Card (British Idiom)
                InputIdiomCard(
                    inputText = uiState.britishIdiomInput,
                    onTextChanged = viewModel::onBritishIdiomChanged,
                    onTranslateClick = viewModel::onTranslateClicked,
                    isLoading = uiState.isLoading,
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                )

                // Output Card (Brazilian Idiom)
                OutputIdiomCard(
                    outputText = uiState.brazilianIdiomOutput,
                    isLoading = uiState.isLoading,
                    errorMessage = uiState.errorMessage,
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                )
            }
        }
    }
}

/**
 * Top Header row featuring the circular translate icon badge and app title.
 */
@Composable
fun IdiomBridgeHeader(modifier: Modifier = Modifier) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(46.dp)
                .clip(CircleShape)
                .background(HeaderIconBackground),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                painter = painterResource(id = R.drawable.ic_translate),
                contentDescription = stringResource(R.string.app_name),
                tint = HeaderIconTint,
                modifier = Modifier.size(24.dp)
            )
        }

        Spacer(modifier = Modifier.width(14.dp))

        Text(
            text = "Idiom Bridge",
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = TextPrimary
        )
    }
}

/**
 * Upper Card where the user inputs the British idiom.
 */
@Composable
fun InputIdiomCard(
    inputText: String,
    onTextChanged: (String) -> Unit,
    onTranslateClick: () -> Unit,
    isLoading: Boolean = false,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(28.dp),
        colors = CardDefaults.cardColors(containerColor = InputCardBackground),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(22.dp)
        ) {
            // Tag Badge
            LanguageBadge(
                flagEmoji = "🇬🇧",
                label = "BRITISH IDIOM",
                backgroundColor = BritishBadgeBackground,
                textColor = BritishBadgeText
            )

            Spacer(modifier = Modifier.height(18.dp))

            // Seamless Input Field
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
            ) {
                BasicTextField(
                    value = inputText,
                    onValueChange = onTextChanged,
                    modifier = Modifier.fillMaxWidth(),
                    textStyle = TextStyle(
                        fontSize = 24.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = TextPrimary
                    ),
                    cursorBrush = SolidColor(TextPrimary),
                    decorationBox = { innerTextField ->
                        if (inputText.isEmpty()) {
                            Text(
                                text = "Type the British idiom",
                                fontSize = 24.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = TextPrimary
                            )
                        }
                        innerTextField()
                    }
                )
            }

            // Translate Action Button
            Button(
                onClick = onTranslateClick,
                enabled = !isLoading,
                shape = RoundedCornerShape(50),
                colors = ButtonDefaults.buttonColors(
                    containerColor = TranslateButtonBackground,
                    contentColor = TranslateButtonContent
                ),
                contentPadding = PaddingValues(horizontal = 18.dp, vertical = 12.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "🇧🇷",
                        fontSize = 16.sp
                    )

                    Spacer(modifier = Modifier.width(8.dp))

                    Text(
                        text = "Translate",
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = TranslateButtonContent
                    )

                    Spacer(modifier = Modifier.width(8.dp))

                    Icon(
                        painter = painterResource(id = R.drawable.ic_arrow_forward),
                        contentDescription = null,
                        tint = TranslateButtonContent,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }
    }
}

/**
 * Lower Card showing the placeholder state or translated Brazilian Portuguese idiom.
 */
@Composable
fun OutputIdiomCard(
    outputText: String?,
    isLoading: Boolean = false,
    errorMessage: String? = null,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(28.dp),
        colors = CardDefaults.cardColors(containerColor = OutputCardBackground),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(22.dp)
        ) {
            // Tag Badge
            LanguageBadge(
                flagEmoji = "🇧🇷",
                label = "BRAZILIAN IDIOM",
                backgroundColor = BrazilianBadgeBackground,
                textColor = BrazilianBadgeText
            )

            // Center Content (Placeholder Empty State)
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f),
                contentAlignment = Alignment.Center
            ) {
                when {
                    isLoading -> {
                        CircularProgressIndicator(
                            color = BrazilianBadgeText
                        )
                    }
                    !errorMessage.isNullOrBlank() -> {
                        Text(
                            text = errorMessage,
                            fontSize = 16.sp,
                            lineHeight = 23.sp,
                            fontWeight = FontWeight.Normal,
                            color = TextSecondary,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                    outputText.isNullOrBlank() -> {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(48.dp)
                                    .clip(RoundedCornerShape(14.dp))
                                    .background(EmptyStateCircleBackground),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    painter = painterResource(id = R.drawable.ic_chat_bubble),
                                    contentDescription = null,
                                    tint = EmptyStateIconTint,
                                    modifier = Modifier.size(24.dp)
                                )
                            }

                            Spacer(modifier = Modifier.height(18.dp))

                            Text(
                                text = "You'll see the Brazilian version of\nthis idiom here",
                                fontSize = 16.sp,
                                lineHeight = 23.sp,
                                fontWeight = FontWeight.Normal,
                                color = TextSecondary,
                                textAlign = TextAlign.Center,
                                modifier = Modifier.widthIn(max = 260.dp)
                            )
                        }
                    }
                    else -> {
                        Text(
                            text = outputText,
                            fontSize = 24.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = TextPrimary,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
            }
        }
    }
}

/**
 * Pill-shaped tag displaying a flag emoji and uppercase language label.
 */
@Composable
fun LanguageBadge(
    flagEmoji: String,
    label: String,
    backgroundColor: Color,
    textColor: Color,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(50),
        color = backgroundColor
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = flagEmoji,
                fontSize = 12.sp
            )

            Spacer(modifier = Modifier.width(6.dp))

            Text(
                text = label,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.6.sp,
                color = textColor
            )
        }
    }
}
