--[[
    Serverside announcements library
    Mostly just a net handler
    See cl_announcements.lua for more information
--]]

-- Serverside function for making a countdown announcement
function GM:CountdownAnnouncement(length, endtext, endsound, ticksound)
    local tbl = {
        type = 'countdown',
        length = length,
        endtext = endtext,
        endsound = endsound,
        ticksound = ticksound
    }
    net.Start('MinigamesAnnouncement')
        net.WriteTable(tbl)
    net.Broadcast()
end

-- Serverside function for making a pulse announcement
function GM:PulseAnnouncement(duration, text, size, sound)
    local tbl = {
        type = 'pulse',
        duration = duration,
        sound = sound,
        text = text,
        size = size,
    }
    net.Start('MinigamesAnnouncement')
        net.WriteTable(tbl)
    net.Broadcast()
end