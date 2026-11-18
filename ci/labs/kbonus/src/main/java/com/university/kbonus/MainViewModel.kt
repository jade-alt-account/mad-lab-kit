package com.university.kbonus

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

fun performHeavyNetworkRequest(url: String): String = "result for $url"

class MainViewModel : ViewModel() {
    val result = MutableLiveData<String>()

    fun load() {
        viewModelScope.launch {                       // starts on the main thread
            // switches to a background thread
            val text = withContext(Dispatchers.IO) {
                performHeavyNetworkRequest("https://api.example.com/data")
            }
            result.value = text                       // back on the main thread
        }
    }
}
