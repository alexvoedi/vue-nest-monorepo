import shell from 'shelljs'
import { defineConfig } from 'tsup'

export default defineConfig({
  entry: ['src/index.ts'],
  splitting: false,
  sourcemap: true,
  clean: true,
  dts: true,
  format: ['cjs', 'esm'],
  silent: true,
  onSuccess: async () => {
    shell.exec('tsc --emitDeclarationOnly --declaration')
  },
})
