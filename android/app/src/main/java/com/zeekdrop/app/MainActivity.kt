package com.zeekdrop.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Explore
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.VideoLibrary
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val Ink = Color(0xFF101014)
private val Panel = Color(0xFF1B1B22)
private val Accent = Color(0xFFFF4D67)
private val Muted = Color(0xFF9A9AA6)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { ZeekDropApp() }
    }
}

@Composable
fun ZeekDropApp() {
    var selected by remember { mutableStateOf("Home") }
    MaterialTheme(colorScheme = darkColorScheme(
        primary = Accent, background = Ink, surface = Panel,
        onBackground = Color.White, onSurface = Color.White
    )) {
        Scaffold(
            containerColor = Ink,
            bottomBar = {
                NavigationBar(containerColor = Panel) {
                    listOf(
                        Triple("Home", Icons.Default.Home, "Home"),
                        Triple("Explore", Icons.Default.Explore, "Explore"),
                        Triple("Library", Icons.Default.VideoLibrary, "Library"),
                        Triple("Profile", Icons.Default.Person, "Profile")
                    ).forEach { (label, icon, route) ->
                        NavigationBarItem(
                            selected = selected == route,
                            onClick = { selected = route },
                            icon = { Icon(icon, contentDescription = label) },
                            label = { Text(label) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = Accent,
                                selectedTextColor = Accent,
                                indicatorColor = Accent.copy(alpha = .15f)
                            )
                        )
                    }
                }
            }
        ) { padding ->
            when (selected) {
                "Home" -> HomeScreen(Modifier.padding(padding))
                "Explore" -> SimpleScreen("Explore", "Find stories by genre, language and mood.", Modifier.padding(padding))
                "Library" -> SimpleScreen("Your library", "Your watchlist and continue-watching list will appear here.", Modifier.padding(padding))
                else -> SimpleScreen("Profile", "Sign in to sync your watch history across devices.", Modifier.padding(padding))
            }
        }
    }
}

@Composable
private fun HomeScreen(modifier: Modifier = Modifier) {
    val titles = listOf("The Last Promise", "Midnight Letters", "A Second Chance")
    LazyColumn(modifier.fillMaxSize(), contentPadding = PaddingValues(20.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("ZEEK", color = Color.White, fontSize = 25.sp, fontWeight = FontWeight.Black)
                Text("DROP", color = Accent, fontSize = 25.sp, fontWeight = FontWeight.Black)
                Spacer(Modifier.weight(1f))
                Text("SHORT STORIES. BIG FEELINGS.", color = Muted, fontSize = 9.sp)
            }
        }
        item {
            Column(Modifier.fillMaxWidth().background(Panel, RoundedCornerShape(24.dp)).padding(20.dp)) {
                Text("FEATURED STORY", color = Accent, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                Spacer(Modifier.height(10.dp))
                Text("Every moment has a story.", color = Color.White, fontSize = 28.sp, fontWeight = FontWeight.Bold, lineHeight = 32.sp)
                Spacer(Modifier.height(8.dp))
                Text("Discover short dramas made for your next free moment.", color = Muted)
                Spacer(Modifier.height(16.dp))
                Button(onClick = {}, colors = ButtonDefaults.buttonColors(containerColor = Accent)) {
                    Text("Explore dramas")
                }
            }
        }
        item { Text("Trending now", color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Bold) }
        items(titles) { title ->
            Row(
                Modifier.fillMaxWidth().background(Panel, RoundedCornerShape(18.dp)).clickable { }.padding(14.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(Modifier.size(width = 76.dp, height = 96.dp).background(Accent.copy(alpha = .22f), RoundedCornerShape(12.dp)), contentAlignment = Alignment.Center) {
                    Icon(Icons.Default.VideoLibrary, contentDescription = null, tint = Accent)
                }
                Spacer(Modifier.width(14.dp))
                Column {
                    Text(title, color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
                    Text("Short drama  •  Preview catalogue", color = Muted, fontSize = 12.sp)
                }
            }
        }
        item { Text("Preview catalogue only — streaming and account sync are not connected yet.", color = Muted, fontSize = 11.sp) }
    }
}

@Composable
private fun SimpleScreen(title: String, subtitle: String, modifier: Modifier = Modifier) {
    Column(modifier.fillMaxSize().padding(24.dp), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
        Text(title, color = Color.White, fontSize = 28.sp, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(8.dp))
        Text(subtitle, color = Muted)
    }
}
