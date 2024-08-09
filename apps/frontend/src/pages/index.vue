<script setup lang="ts">
import { text } from 'common'

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
    <h1>{{ text }}</h1>
    <pre>{{ data }}</pre>
  </div>
</template>

<style>
</style>
