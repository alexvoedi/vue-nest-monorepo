import { defineProject, mergeConfig } from 'vitest/config'
import viteConfig from './vite.config'

const vitestConfig = defineProject({
  test: {
    name: 'frontend',
    environment: 'jsdom',
    include: ['**/*.test.ts'],
  },
})

export default mergeConfig(viteConfig, vitestConfig)
