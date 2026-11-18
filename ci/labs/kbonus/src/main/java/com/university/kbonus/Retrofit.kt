package com.university.kbonus

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
import java.io.IOException

data class User(val id: Int, val name: String, val email: String)

interface UserApi {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: Int): User
}

val api: UserApi = Retrofit.Builder()
    .baseUrl("https://jsonplaceholder.typicode.com/")
    .addConverterFactory(GsonConverterFactory.create())
    .build()
    .create(UserApi::class.java)

class UserViewModel : ViewModel() {
    val result = MutableLiveData<String>()

    fun load() {
        viewModelScope.launch {
            try {
                val user = api.getUser(1)          // Retrofit runs the call off the main thread
                result.value = "${user.name} <${user.email}>"
            } catch (e: IOException) {
                result.value = "Request failed: ${e.message}"
            }
        }
    }
}
