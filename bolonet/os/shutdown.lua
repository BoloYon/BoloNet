local G = ...

term.setBackgroundColor(colors.black)
term.clear()

G.ui.CalcCenter("Shutting down in:", 0, -1, write, colors.yellow)

for i = 3, 1, -1 do
    G.ui.CalcCenter(tostring(i), 0, 1, write, colors.red)
    sleep(1)
end
G.logger.Log("SYSTEM", "BoloNet shutdown\n")
os.reboot()