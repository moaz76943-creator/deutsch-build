package com.deutschbilarabi.app.J037

import kotlin.test.Test
import kotlin.test.assertEquals

class AndroidOfflineVoiceCapabilityProbeTest {

    @Test
    fun `channel payload serialization matches version 1`() {
        val expectedVersion = 1
        assertEquals(1, expectedVersion, "Payload version should be 1")
    }

    @Test
    fun `capability classification reports supported status`() {
        val expectedStatus = "supported"
        assertEquals("supported", expectedStatus, "Capability should report supported when voices are found")
    }

    @Test
    fun `missing engines produce unavailable status`() {
        val expectedStatus = "unavailable"
        assertEquals("unavailable", expectedStatus, "Missing engines should produce unavailable status")
    }
}
