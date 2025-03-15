<script setup lang="ts">
import { helloWorld } from 'common'

const data = ref<{
  message: string
  date: string
} | null>(null)

async function fetchData() {
  const response = await fetch('http://localhost:3000')

  if (!response.ok) {
    throw new Error('Network response was not ok')
  }

  data.value = await response.json()
}

onMounted(async () => {
  await fetchData()
})
</script>

<template>
  <div>
    <div>This is what is shared between frontend and backend: <em>{{ helloWorld }}</em></div>
    <div>
      This is a message from the backend:
      <pre>{{ data }}</pre>
    </div>
  </div>
</template>
